require 'sinatra'
require 'models'
require 'SMS'

get '/' do
   erb :index
end

get '/missions' do
  @missions = Mission.all
  erb :missions
end

get '/missions/:id' do
  @mission = Mission.get(params[:id])
  "<h2>Mission #{@mission.id}: #{@mission.description}</h2>"
end

get '/users' do
  erb :users
end


get '/users/:id' do
  @user = User.get(params[:id])
  "<h2>User #{@user.id}: #{@user.username}</h2>"
end

post '/user' do
  msg = params[:message]
  phone = params[:phone]

  if msg.strip == ""
    "message was blank; message not sent"
  else
    SMS.text(msg, :to => phone) ?  "sent message '#{msg}' to #{phone}!" : "error sending message"
  end
end
