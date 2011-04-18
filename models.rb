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

  has n, :documents
end

class Mission
  include DataMapper::Resource

  property :id, Serial
  property :description, String

  has n, :categories, :through => Resource
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
