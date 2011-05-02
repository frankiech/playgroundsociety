require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite://' + Dir.pwd + '/db/cpa.db')

class User
  include DataMapper::Resource

  property :id, Serial
  property :login, String
  property :hashed_password, String
  property :phone, String
  property :created_at, DateTime, :default => DateTime.now
  property :admin, Boolean, :default => false
  property :active, Boolean, :default => true
  property :last_mission, Integer, :default => 1
  property :name, String
  property :email, String
  property :location, String

  has n, :documents
  has n, :messages

  def self.encrypt(pass)
    Digest::SHA1.hexdigest(pass)
  end

  def self.authenticate(login, pass)
    u = User.first(:login => login)
    return nil if u.nil?
    return true if User.encrypt(pass) == u.hashed_password
    nil
  end

end

class Message
  include DataMapper::Resource

  property :id, Serial
  property :message, String
  property :comment, String
  property :sent, Boolean, :default => true
  property :time_sent, DateTime, :default => DateTime.now

  has n, :missions, :through => Resource
  belongs_to :user
end

class Mission
  include DataMapper::Resource

  property :id, Serial
  property :description, Text

  has n, :categories, :through => Resource
  has n, :messages, :through => Resource
  has n, :documents
  belongs_to :campaign
end

class Campaign
  include DataMapper::Resource

  property :id, Serial
  property :description, String

  has n, :mission
end

class Category
  include DataMapper::Resource

  property :id, Serial
  property :description, String

  has n, :missions, :through => Resource
end

class Document
  include DataMapper::Resource

  property :id, Serial
  property :path, String
  property :description, Text
  property :created_at, DateTime

  belongs_to :user
  belongs_to :mission
end

DataMapper.finalize
DataMapper.auto_upgrade!
