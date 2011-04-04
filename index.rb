require 'sinatra'
require 'haml'
require 'rack-flash'
require 'models'
require 'SMS'

use Rack::Flash
enable :sessions

get '/' do
  haml :index
end

get '/missions' do
  haml :missions_list, :locals => {:missions => Mission.all}
end

get '/missions/:id/edit' do |id|
  haml :mission_update, :locals => {:mission => Mission.get(id), 
                                    :action => "/missions/#{id}/update"}
end

post '/missions/:id/update' do |id|
  mission = Mission.get(id)
  mission.update params
  redirect '/missions'
end

get '/users' do
  haml :users_list, :locals => {:users => User.all}
end

get '/users/:id/edit' do |id|
  flash[:notice] = "edit #{id}"
  haml :user_update, :locals => {:user => User.get(id), :action => "/users/#{id}/update"}
end

post '/users/:id/update' do |id|
  user = User.get(id)
  user.update params
  redirect '/users'
end

post '/users/:id/sendsms' do |id|
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
  redirect '/users'
end
