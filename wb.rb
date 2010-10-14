require 'rubygems'
require 'dm-core'
require 'dm-migrations/adapters/dm-sqlite-adapter'
require 'sinatra'
require 'erb'
require 'date'
require 'uri'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3:accesses.sqlite3')

class Access
  include DataMapper::Resource
  
  property :id,        Serial
  property :timestamp, DateTime
  property :host,      String
  property :method,    String
  property :referrer,  String
  
  has n, :form_data_pairs
end

class FormDataPair
  include DataMapper::Resource
  
  property :id,       Serial
  property :name,     String
  property :value,    Text
end

DataMapper.auto_migrate!


# Log requests made to /
get '/' do
  access = Access.new
  access.host = @env['REMOTE_ADDR']
  access.referrer = request.referer
  access.timestamp = DateTime.now
  
  access.method = 'GET'
  request.GET.each_pair do |key, value|
    pair = FormDataPair.new
    pair.name = key
    pair.value = value
    access.form_data_pairs << pair
  end
  
  access.save
  
  status 404
  'No one here but us chickens.'
end


get '/admin' do
   redirect '/admin/list'
end


get '/admin/list' do
  @entries = Access.all(:order => [ :timestamp.desc ])
  erb :hitlist
end


get '/admin/payloads' do
   @entries = [{
      :title => 'Sample Payload',
      :author => 'Anonymous J. Hacker',
      :description => 'This is a sample payload.',
      :shortname => 'sample'
   }]
   erb :payloads
end