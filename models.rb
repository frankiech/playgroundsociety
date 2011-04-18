require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite://' + Dir.pwd + '/db/cpa.db')

class User
  include DataMapper::Resource

  property :id, Serial
  property :username, String
  property :password_hash, String
  property :last_mission, Integer
  property :phone, String
end

class Mission
  include DataMapper::Resource

  property :id, Serial
  property :description, String

  has n, :categories, :through => Resource
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

DataMapper.finalize
DataMapper.auto_upgrade!
