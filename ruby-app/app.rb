require 'sinatra'

get '/' do
  "Hello, world! Running Ruby #{RUBY_VERSION}!"
end
