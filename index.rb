require 'rubygems'
require 'sinatra'
require 'haml'
require 'rack-flash'
require 'digest/sha1'
require 'models'
require 'SMS'
require 'aws/s3'

use Rack::Flash
enable :sessions

helpers do
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials == [ENV['PS_USER'], ENV['PS_PASSWORD']]
  end
end

get '/' do
  haml :index
end

get '/play' do
  haml :play
end

get '/about' do
  haml :about
end

get '/signup' do
  haml :signup, :locals => {:action => "/signup"}
end

post '/signup' do
  user = User.create(:password_hash => Digest::SHA1.hexdigest(params[:password]), 
                     :username => params[:username], :phone => params[:phone]);
  flash[:notice] = "Thanks for signing up! You will recieve your first mission within 72 hours."
  redirect '/signup'
end

get '/missions/:id' do |id|
  # Show a mission with documentation
  haml :mission_profile
end

get '/users/:id' do |id|
  # User profile page with documentation
  haml :user_profile
end

get '/users/:id/new_document' do |id|
  # Form to post a file
  haml :new_document, :locals => {:action => "/users/#{id}/post_document"}
end

post '/users/:id/post_document' do |id|
  # Post the documentation to Amazon S3
  if params[:file] and params[:mission_id]
    filename = params[:file][:filename]
    file = params[:file][:tempfile]

    AWS::S3::Base.establish_connection!(:access_key_id => ENV["AWS_ACCESS_KEY"], :secret_access_key => ENV["AWS_SECRET_KEY"])
    AWS::S3::S3Object.store(id + filename, open(file), "playgroundsociety", :access => :public_read)

    Document.create(:path => filename, :description => params[:description], :created_at => Time.now, :user_id => id, :mission_id => params[:mission_id])
    flash[:notice] = "Successfully uploaded your documentation for Mission # #{params[:mission_id]}!"
  else
    flash[:notice] = "Error uploading documentation. Please enter a mission and attach a file."
  end

  redirect "/users/#{id}/new_document"
end

before '/admin/*' do
  protected!
end

get '/admin/missions' do
  haml :missions_list, :locals => {:missions => Mission.all}
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
  msg = params[:message]
  phone = User.get(id).phone

  if msg.strip == ""
    flash[:notice] = "Message was blank; Nothing was sent"
  else
    if SMS.text(msg, :to => phone) then
      flash[:notice] = "Sent message '#{msg}' to #{phone}!" 
    else
      flash[:notice] = "Error sending message '#{msg}' to #{phone}."
    end
  end
  redirect '/admin/users'
end
