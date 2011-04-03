require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite://' + Dir.pwd + '/db/cpa.db')

class Mission
  include DataMapper::Resource

  property :id, Serial
  property :description, String
  property :category, String
end

class User
  include DataMapper::Resource

  property :id, Serial
  property :username, String
  property :password_hash, String
  property :last_mission, Integer
  property :phone, String
end

def load_missions
  Mission.create(:description => "Place your hand on the wall for 5 full seconds and fully BELIEVE that this will fuel your ability to move through the world with excellent playfulness.  Repeat as necessary.")
  Mission.create(:description => "At some point when you are around a group of people, preferably strangers, pretend that several people in a row that you pass can hear a single thought that you choose to send to their mind.  Hopefully you will send them a compliment in some form.")
  Mission.create(:description => "At some point in the next hour find a place to skip for at least 15 steps.")
  Mission.create(:description => "Ask someone if you can try on their glasses.  Pretend that when you put on the glasses you will be able to recognize an object in the room that has magical powers.  Keep this object in mind while you’re in the space.")
  Mission.create(:description => "Find a cup of water to drink.  Before drinking the water, look at it and pretend that these particular hydrogen and oxygen atoms will enter your body and provide a super boost to your immune system.  Repeat as necessary.")
  Mission.create(:description => "Don’t be too creepy about it, but the next friend you see, shake their hand, or give them a hug, or put your hand on their shoulder and pretend that the energy passing from you to them will somehow be converted into a new idea, for them, that they’ll be excited about.")
  Mission.create(:description => "Say the following words aloud: Shit just got real.  As you repeat these words aloud throughout the day, BELIEVE that they are helping to develop your AWESOMENESS.")
  Mission.create(:description => "Enter a building that you have passed many times but never gone in.  Once inside, look for, listen for, or feel for a specific detail.  You will know it when you see it, hear it, or feel it.  Pretend that this small detour form your normal routine, and the detail, is a key to unlocking a mystery that you do not yet know even exists.")
  Mission.create(:description => "Within the next hour, locate the first object in your new collection.  It does not need to be an object you can put in your pocket, but it should be something that at the very least you see, and remember, and place into a mental list as item 1 in the new collection.  Or, the best suggestion: pick up a random object as the first item.")
  Mission.create(:description => "Quickly think of a song that you loved in high school.  Quickly choose a single word from the song.  Spell it out somewhere that you can see for the rest of the day and perhaps beyond.")
  Mission.create(:description => "Call someone who you have not spoken with for 6 months.  Engage in a normal conversation, but pull from that conversation a single phrase, and then include the phrase in an email (or facebook message) that to another friend who you also haven’t interacted with for months.")
  Mission.create(:description => "Find a good spot outside to do 20 jumping jacks.  It could be alone or in a group of people, whatever feels right.")
  Mission.create(:description => "Clap your hands together one time. So much just happened.  (Repeat throughout the day when it occurs to you to do so.)")
  Mission.create(:description => "At some point before your day ends, either go to a grocery store and buy something to eat that you’ve never had before, or, go to a store that sells shoes and try on a pair of shoes that you’d never buy.")
  Mission.create(:description => "Today’s play mission involves your favorite number.  If you do not have one, choose any number that you even sort of like.  Write the number on your hand with a pen.  Be aware of things that happen in reference to the number on your hand, when people mention it, when you recognize it, when you see that number in other places, etc.  PLAY.")
  Mission.create(:description => "Pretend you are invisible until someone acknowledges you and then ask them, aloud, “You can see me?”  (Repeat if enjoyable.)")
  Mission.create(:description => "Recall your favorite toy as a child.  (Is there any sort of connection between the toy and the first object in your new collection from 8 missions ago?) Think about what it was about that toy that you liked so much?  Spend some time today playing with that toy in your mind.")
  Mission.create(:description => "Raise your hands high above your head.  In the next hour, touch several things with your fingertips that are at that height.")
  Mission.create(:description => "Paint a surface with your hands.  Imagine you’re making a drawing or a painting.  Create a specific image, even if it’s abstract.  If you can’t think of anything to draw, draw the first object in your new collection.")
  Mission.create(:description => "Think back to a favorite teacher from ages 5 to 18, or even from college.  Think about what it was that you liked about that teacher.  Play with the idea of presenting yourself in a similar way to people you interact with in the next few hours.")
  Mission.create(:description => "Close your eyes and pretend that the darkness you see with your eyes closed also means that you are actually in a dark room.  (if you’re in a dark room, that’s ok too.)  with your eyes closed, pretend that you and everyone else in the room is glowing in an array of neon colors.  Repeat throughout the day as it occurs to you to do so.")
end

DataMapper.finalize
DataMapper.auto_upgrade!
