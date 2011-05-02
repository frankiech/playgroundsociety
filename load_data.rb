
def load_campaigns
  Campaign.create(:description => "Play Mission")
end

def load_categories
  Category.create(:description => "Physical")
  Category.create(:description => "Pretend")
  Category.create(:description => "Relax")
  Category.create(:description => "Social")
end


def load_missions
  Mission.create(:campaign_id => 1, :description => "Write a number on your hand in ink. Maintain a curious awareness of that number today: Who comments on it? Where else does it appear?")
  Mission.create(:campaign_id => 1, :description => "As you pass people, pretend each one can hear a single thought you choose to send to their mind. Send a compliment, a surreal image, or…?")
  Mission.create(:campaign_id => 1, :description => "At some point in the next hour, find a moment and a space to skip for at least 15 steps.")
  Mission.create(:campaign_id => 1, :description => "Ask to try on someone’s glasses. Pretend that when you put them on, you’ll recognize a nearby object with magical powers.")
  Mission.create(:campaign_id => 1, :description => "Pour a glass of water. For 5 seconds, imagine these particular hydrogen & oxygen atoms bursting with creative-immune boost. Drink the water.")
  Mission.create(:campaign_id => 1, :description => "Shake hands with, hug, or touch the shoulder of a friend. Imagine passing them an energy current that will become their next exciting idea.")
  Mission.create(:campaign_id => 1, :description => "Say this aloud: Shit just got real. As you repeat these words throughout the day, BELIEVE they are developing your AWESOMENESS skills.")
  Mission.create(:campaign_id => 1, :description => "Go into a building you’ve never entered. Once inside look for a specific detail. Pretend it is info that unlocks a mystery or a problem.")
  Mission.create(:campaign_id => 1, :description => "In the next hour, locate the first item in your new collection. It doesn’t have to be anything you take with you. Just notice it: item #1!")
  Mission.create(:campaign_id => 1, :description => "Quickly: think of a song you loved in high school. Choose one word from the song. Spell it out where you can see for the rest of the day.")
  Mission.create(:campaign_id => 1, :description => "Call someone you haven’t spoken with in a long time. Jot down a phrase they use. Include it in an email to another old friend today.")
  Mission.create(:campaign_id => 1, :description => "Take a break and go find a good spot outside to do 20 jumping jacks. It could be alone, in a group of people, whatever feels right.")
  Mission.create(:campaign_id => 1, :description => "Clap your hands together once. So much just happened: dust, planes, molecules, births. Repeat throughout the day, as it occurs to you.")
  Mission.create(:campaign_id => 1, :description => "Stop by a market today and buy a food you’ve never tried. Or: visit a shoe store and try on a pair you’d never buy in a million years.")
  Mission.create(:campaign_id => 1, :description => "Place your hand on the wall for 5 full seconds. BELIEVE this act fuels your ability to move through the world playfully. Repeat as needed.  ")
  Mission.create(:campaign_id => 1, :description => "For a while today, pretend you're invisible until someone acknowledges you. Then say, “You can see me?” (Repeat as desired, if it's fun.)")
  Mission.create(:campaign_id => 1, :description => "Think of your favorite childhood toy. What did you like about it so much? Spend a few minutes today playing with that toy in your mind.")
  Mission.create(:campaign_id => 1, :description => "Think of your favorite childhood toy again. Is there a connection between the toy & the first object in your new collection from last week?")
  Mission.create(:campaign_id => 1, :description => "Find an opportunity to raise your hands high above your head and touch things at that height: doorways, tree branches, signage, what else?")
  Mission.create(:campaign_id => 1, :description => "Paint a surface with your hands. Imagine you’re making a specific image, even if abstract. When you're done, mime hanging it on the wall.")
  Mission.create(:campaign_id => 1, :description => "Think back to a favorite teacher. What did you like so much about them? Play at embodying that quality in your interactions w/ people today.")
  Mission.create(:campaign_id => 1, :description => "Close your eyes and pretend the lights have gone out. (Or turn the lights off.) Imagine you and everyone around you glowing in neon colors.")
end

def load_all
  load_categories
  load_campaigns
  load_missions
end

load_all


