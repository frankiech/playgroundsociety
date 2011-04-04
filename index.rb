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

__END__

@@layout
!!! 5
%html
  %head
    %title Playground Society
    %link(href="/css/reset.css" rel="stylesheet")
    %link(href="/css/style.css" rel="stylesheet")
  %body
    = yield
    .footer
      %a(href="/") Home

@@index
%header
  %h1 Welcome to Playground Society!

@@missions_list
%header
  %h1 Missions
%table
  %tr
    %th id
    %th Description
    %th Actions
  - missions.each do |mission|
    %tr
      %td= mission.id
      %td= mission.description
      %td
        %a(href="/missions/#{mission.id}/edit") Edit

@@mission_update
%header
  %h1= "Update Mission #{mission.id}"
.edit
  %form(action="#{action}" method="POST")
    %label
      Description:
      %br
      %textarea.edit(name="description")= mission.description
    %br
    %input(type="submit" value="Update Mission")
    %input(type="reset")

    -# %form(action="/missions/#{mission.id}/destroy" method="POST")
    -#  %input(type="submit" value="Delete Mission")


@@user_update
%header
  %h1= "Update User #{user.id}"
.edit
  %form(action="#{action}" method="POST")
    %label
      Username: 
      %input(type="text" name="username" value="#{user.username}")
    %br

    %label
      Phone: 
      %input(type="text" name="phone" value="#{user.phone}")
    %br
    %input(type="submit" value="Update User")
    %input(type="reset")

@@users_list
%header
  %h1 Users
  %h3= flash[:notice]
%table
  %tr
    %th id
    %th Name
    %th Phone
    %th SMS
    %th Edit
  - users.each do |user|
    %tr
      %td= user.id
      %td= user.username
      %td= user.phone
      %td
        %form(action="/users/#{user.id}/sendsms" method="POST")
          .sms_input
            %textarea.edit(name="message" placeholder="Write a SMS message")
            %br/
            %input(type="submit" value="Send SMS")
      %td
        %a(href="/users/#{user.id}/edit") Edit
