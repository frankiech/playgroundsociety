require 'rubygems'
require 'sinatra'
require 'haml'
require 'rack-flash'
require 'rack-ssl-enforcer'
require 'digest/sha1'
require 'models'
require 'SMS'
require 'aws/s3'
require 'mini_magick'

use Rack::Flash
# use Rack::SslEnforcer
enable :sessions

### Helpers
helpers do
  def protected!
    unless admin?
      redirect '/'
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
    message = Mission.get(1).description
    SMS.text(message, :to => params[:phone])
    flash[:notice] = "Thanks for signing up! Please check your phone for a welcome message and your first play mission!"
    user = User.create(:hashed_password => User.encrypt(params[:password]), 
                     :login => params[:login], :phone => params[:phone]);
    # Message.create(:message => welcome_sms, :user_id => user.id, :sent => true)
    # Message.create(:message => message, :user_id => user.id, :sent => true)
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
  haml :user_profile, :locals => {:user => User.get(session[:user_id]), :private => true}
end

before '/account/*' do
  authorize!
end

get '/account/document/delete/:id' do |id|
  doc = Document.get(id)
  if doc.user_id = session[:user_id]
    doc.destroy
    flash[:notice] = "Deleted document"
    redirect '/account'
  else
    flash[:notice] = "Could not delete this document."
    redirect '/account'
  end
end

get '/account/update_profile' do
  haml :user_edit, :locals => {:user => User.get(session[:user_id]), :action => "/account/update"}
end

post '/account/update' do
  user = User.get(session[:user_id])
  params['hashed_password'] = user.hashed_password
  params['hashed_password'] = User.encrypt(params['password']) if params['password']
  params.delete 'password'
  user.update params
  flash[:notice] = "Profile updated."
  redirect '/account'
end

get '/account/document/edit/:id' do |id|
  doc = Document.get(id)
  unless doc.user_id == session[:user_id] or admin?
    flash[:notice] = "Cannot edit that document."
    redirect '/account'
  end
  haml :document_edit, :locals => {:action => "/account/document/update/#{id}", :doc => doc, :missions => Mission.all(:id.lte => session[:last_mission])}
end

post '/account/document/update/:id' do |id|
  doc = Document.get(id)
  
  if params[:file] and params[:mission_id]
    filename = params[:file][:filename]
    file = params[:file][:tempfile]
    save_file = filename.gsub(" ", "")

    AWS::S3::Base.establish_connection!(:access_key_id => ENV["AWS_ACCESS_KEY"], :secret_access_key => ENV["AWS_SECRET_KEY"])
    AWS::S3::S3Object.store(session[:user_id].to_s + save_file, open(file), "playgroundsociety", :access => :public_read)
    tn_generate_and_upload("http://playgroundsociety.s3.amazonaws.com/", session[:user_id].to_s + save_file)

    Document.get(id).update(:path => save_file, :description => params[:description], :created_at => Time.now, :user_id => doc.user_id, :mission_id => params[:mission_id])
    msg = "Successfully updated document and uploaded your new file."
  else
    msg = "Updated document but did not upload file."
  end
  params.delete 'file'
  doc.update params
  flash[:notice] = msg
  redirect "/account/document/edit/#{id}"
end

get '/account/document/new' do
  # Form to post a file
  haml :document_new, :locals => {:action => "/account/document/post", :missions => Mission.all(:id.lte => session[:last_mission])}
end

post '/account/document/post' do
  # Post the documentation to Amazon S3
  if params[:file] and params[:mission_id]
    filename = params[:file][:filename]
    file = params[:file][:tempfile]
    save_file = filename.gsub(" ", "")

    AWS::S3::Base.establish_connection!(:access_key_id => ENV["AWS_ACCESS_KEY"], :secret_access_key => ENV["AWS_SECRET_KEY"])
    AWS::S3::S3Object.store(session[:user_id].to_s + save_file, open(file), "playgroundsociety", :access => :public_read)
    tn_generate_and_upload("http://playgroundsociety.s3.amazonaws.com/", session[:user_id].to_s + save_file)

    Document.create(:path => save_file, :description => params[:description], :created_at => Time.now, :user_id => session[:user_id], :mission_id => params[:mission_id])
    flash[:notice] = "Successfully uploaded your documentation for Mission # #{params[:mission_id]}!"
  else
    flash[:notice] = "Error uploading documentation. Please enter a mission and attach a file."
  end

  redirect "/account/document/new"
end

### User Pages
before '/users/*' do
  authorize!
end

get '/users/:id' do |id|
  haml :user_profile, :locals => {:user => User.get(id), :private => false}
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

get '/admin/missions/add' do |id|
  m = Mission.create(:description => "Placeholder", :campaign_id => 1)
  flash[:notice] = "Added Mission #{m.id}"
  redirect '/admin/missions'
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
  params['hashed_password'] = user.hashed_password
  params['hashed_password'] = User.encrypt(params['password']) if params['password']
  params.delete 'password'
  user.update params
  flash[:notice] = "User #{user.login} updated."
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
      user.update(:last_mission => [mission_id.to_i, user.last_mission].max)
      # Message.create(:message => msg, :user_id => user.id, :sent => true)
      flash[:notice] = "Sent message '#{msg}' to #{phone}!" 
    else
      flash[:notice] = "Error sending message '#{msg}' to #{phone}."
      # Message.create(:message => msg, :user_id => user.id, :sent => false)
    end
  end
  redirect '/admin/users'
end

get '/admin/send_all' do |id|
  flash[:notice] = send_all_sms
  redirect '/admin/users'
end

### other functions
def send_all_sms
  successes = 0
  fails = 0
  User.all.each do |user|
    mission_id = user.last_mission + 1
    msg = Mission.get(mission_id).description
    phone = user.phone
    if SMS.text(msg, :to => phone) then
      user.update(:last_mission => mission_id)
      comment = "BULK: Sent message to #{phone}!"
      # Message.create(:message => msg, :user_id => user.id, :comment => comment, :sent => true)
      successes += 1
    else
      comment = "BULK: Error sending to #{phone}."
      # Message.create(:message => msg, :user_id => user.id, :comment => comment, :sent => false)
      fails += 1
    end
  end
  "Successes: #{successes}, Fails: #{fails}"
end

def find_stray_images
  AWS::S3::Base.establish_connection!(:access_key_id => ENV["AWS_ACCESS_KEY"], :secret_access_key => ENV["AWS_SECRET_KEY"])
  s3_files = AWS::S3::Bucket.objects('playgroundsociety').select{|o| o.key =~ /^[^tn\.]/}.map{|o| o.key}
  doc_files = Document.all.map{|doc| "#{doc.user_id}#{doc.path}"}

  s3_files - doc_files
end

def del_s3_files(bucket, regex, filearray)
  AWS::S3::Base.establish_connection!(:access_key_id => ENV["AWS_ACCESS_KEY"], :secret_access_key => ENV["AWS_SECRET_KEY"])
  filearray.each do |f|
    AWS::S3::S3Object.delete f, bucket
  end
end

def rename_spaced_s3_files(opts = {})
  # default to bucket = 'playgroundsociety' and regex = /^[^tn\.]/
  bucket = opts[:bucket] || 'playgroundsociety'
  regex = opts[:regex] || /^[^tn\/*]/

  # find and rename files with spaces to files without spaces
  AWS::S3::Base.establish_connection!(:access_key_id => ENV["AWS_ACCESS_KEY"], :secret_access_key => ENV["AWS_SECRET_KEY"])
  AWS::S3::Bucket.objects(bucket).select{|o| o.key =~ regex}.grep(/\s/) do |o|
    puts "s3: renaming #{o.key} to #{o.key.gsub(" ", "")}"
    o.rename "#{o.key.gsub(" ", "")}"
    puts "done"
  end

  # find and rename Document paths with spaces to files without spaces
  Document.all.select{|doc| doc.path =~ /\s/}.each do |doc| 
    puts "document renaming #{doc.path} to #{doc.path.gsub(" ", "")}"
    doc.update(:path => doc.path.gsub(" ", ""))
  end
end

def tn_generate_and_upload(domain, filepath)
  filename = filepath.split('/').last.gsub(" ", "")
  img = MiniMagick::Image.open("#{domain}#{filepath}")
  img.resize '110x'
  img.write "tmp/#{filename}"
  AWS::S3::Base.establish_connection!(:access_key_id => ENV["AWS_ACCESS_KEY"], :secret_access_key => ENV["AWS_SECRET_KEY"])
  AWS::S3::S3Object.store("tn/#{filename}", open("tmp/#{filename}"), "playgroundsociety", :access => :public_read)
  `rm tmp/#{filename}`
  "#{filename} stored to tn/#{filename}"
end

def generate_thumbs
  AWS::S3::Base.establish_connection!(:access_key_id => ENV["AWS_ACCESS_KEY"], :secret_access_key => ENV["AWS_SECRET_KEY"])
  s3_files = AWS::S3::Bucket.objects('playgroundsociety').select{|o| o.key =~ /^[^tn\.]/}.map{|o| o.key}. each do |f|
    puts tn_generate_and_upload("http://playgroundsociety.s3.amazonaws.com/", f)
  end
end

