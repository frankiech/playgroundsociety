source :rubygems

gem "sinatra"
gem "dm-core"
gem "dm-migrations"
gem "twiliolib"
gem "haml"
gem "rack-flash"
gem "rack-ssl-enforcer"
gem 'aws-s3', :require => "aws/s3"

group :development do
  gem 'dm-sqlite-adapter'
end

group :production do
  gem 'dm-postgres-adapter'
  gem 'do_postgres'
end
