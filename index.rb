require 'rubygems'
require 'sinatra'
require 'haml'
require 'rack-flash'
require 'rack-ssl-enforcer'
require 'digest/sha1'
require 'models'
require 'SMS'
require 'aws/s3'

use Rack::Flash
# use Rack::SslEnforcer
enable :sessions

### Helpers
helpers do
  def protected!
    unless admin?
      flash[:notice] = "Please log in with an admin account."
      redirect '/login'
    end
  end

  def admin?
    return true if session[:admin]
  end

  def authorized?
    return true if session[:user]
  end

  def authorize!
    redirect '/login' unless authorized?
  end

  def logout!
    session[:user] = false
    session[:user_id] = false
    session[:admin] = false
  end
end

### Static Pages
get '/' do
  haml :index
end

get '/play' do
  haml :play
end

get '/about' do
  haml :about
end

### User Management
get '/signup' do
  haml :signup, :locals => {:action => "/signup"}
end

post '/signup' do
  welcome_sms = "Welcome to Playground Society.  We hope you'll enjoy a few moments of play each week.  The first Play Mission will be sent to you shortly!"
  if SMS.text(welcome_sms, :to => params[:phone])
    SMS.text(Mission.get(1).description, :to => params[:phone])
    flash[:notice] = "Thanks for signing up! Please check your phone for a welcome message and your first play mission!"
    user = User.create(:hashed_password => User.encrypt(params[:password]), 
                     :login => params[:login], :phone => params[:phone]);
  else
    flash[:notice] = "Your phone number is invalid.  Please update your phone number."
  end
  redirect '/signup'
end

get '/login' do
  redirect '/account' if authorized?
  haml :login, :locals => {:action => "/login"}
end

post '/login' do
  if session[:user] = User.authenticate(params[:login], params[:password])
    flash[:notice] = "Login successful."
    session[:login] = params[:login]
    session[:user_id] = User.first(:login => params[:login]).id
    session[:last_mission] = User.get(session[:user_id]).last_mission
    session[:admin] = User.get(session[:user_id]).admin
    redirect "/account"
  else
    flash[:notice] = "Login failed. Try again."
    redirect "/login"
  end
end

get '/logout' do
  flash[:notice] = "You have logged out."
  logout!
  redirect '/'
end


### User Account Pages
get '/account' do
  redirect '/login' unless authorized?
  haml :user_profile, :locals => {:user => User.get(session[:user_id])}
end

before '/account/*' do
  authorize!
end

get '/account/new_document' do
  # Form to post a file
  haml :new_document, :locals => {:action => "/account/post_document", :missions => Mission.all(:id.lte => session[:last_mission])}
end

post '/account/post_document' do
  # Post the documentation to Amazon S3
  if params[:file] and params[:mission_id]
    filename = params[:file][:filename]
    file = params[:file][:tempfile]

    AWS::S3::Base.establish_connection!(:access_key_id => ENV["AWS_ACCESS_KEY"], :secret_access_key => ENV["AWS_SECRET_KEY"])
    AWS::S3::S3Object.store(session[:user_id].to_s + filename, open(file), "playgroundsociety", :access => :public_read)

    Document.create(:path => filename, :description => params[:description], :created_at => Time.now, :user_id => session[:user_id], :mission_id => params[:mission_id])
    flash[:notice] = "Successfully uploaded your documentation for Mission # #{params[:mission_id]}!"
  else
    flash[:notice] = "Error uploading documentation. Please enter a mission and attach a file."
  end

  redirect "/account/new_document"
end

### Mission Pages
get '/missions' do
  redirect '/play' unless authorized?
  haml :missions_list, :locals => {:missions => Mission.all(:id.lte => session[:last_mission]), :editable => false}
end

before '/missions/*' do
  authorize!
end

get '/missions/:id' do |id|
  # Show a mission with documentation
  redirect '/missions' if id.to_i > session[:last_mission]
  haml :mission_profile, :locals => {:mission => Mission.get(id)}
end


### Admin Pages
before '/admin/*' do
  protected!
end

get '/admin/missions' do
  haml :missions_list, :locals => {:missions => Mission.all, :editable => true}
end

get '/admin/missions/:id/edit' do |id|
  haml :mission_edit, :locals => {:mission => Mission.get(id), :action => "/admin/missions/#{id}/update"}
end

post '/admin/missions/:id/update' do |id|
  mission = Mission.get(id)
  mission.update params
  redirect '/admin/missions'
end

get '/admin/users' do
  haml :users_list, :locals => {:users => User.all}
end

get '/admin/users/:id' do |id|
  haml :user_profile, :locals => {:user => User.get(id)}
end

get '/admin/users/:id/edit' do |id|
  haml :user_edit, :locals => {:user => User.get(id), :action => "/admin/users/#{id}/update"}
end

post '/admin/users/:id/update' do |id|
  user = User.get(id)
  user.update params
  redirect '/admin/users'
end

get '/admin/users/:id/delete' do |id|
  user = User.get(id)
  user.destroy
  flash[:notice] = "Deleted User #{id}."
  redirect '/admin/users'
end

post '/admin/users/:id/sendsms' do |id|
  mission_id = params[:mission_id]
  msg = Mission.get(mission_id).description
  user = User.get(id)
  phone = user.phone

  if msg.strip == ""
    flash[:notice] = "Message was blank; Nothing was sent"
  else
    if SMS.text(msg, :to => phone) then
      user.update(:last_mission => mission_id)
      Message.create(:message => msg, :user_id => user.id)
      flash[:notice] = "Sent message '#{msg}' to #{phone}!" 
    else
      flash[:notice] = "Error sending message '#{msg}' to #{phone}."
    end
  end
  redirect '/admin/users'
end


