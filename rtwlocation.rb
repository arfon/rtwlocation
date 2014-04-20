require 'sinatra'
require 'twilio-ruby'
require 'json'
require 'octokit'

configure :production do
  require 'newrelic_rpm'
end

get '/' do
  "Alive!"
end

post '/sms-receive' do
  lat_lng = params[:Body]
  lat, lng = lat_lng.split(',').map(&:strip)
  
  current_location = latest_geom_position_from(lat,lng)
  update_gist_location(current_location)
  
  twiml = Twilio::TwiML::Response.new do |r|
    r.Message "OK, I've got you at https://www.google.com/maps/preview?q=##{lat},#{lng}"
  end
  twiml.text
end

def update_gist_location(position)
  client = Octokit::Client.new(:access_token => ENV['GH_TOKEN'])
  old_geo = JSON.load(File.open('lowe2014.geojson', 'r').read)
  old_geo["features"] << position
  
  client.edit_gist(ENV['GIST_ID'], {
    :files => {"lowe2014.geojson" => {"content" => JSON.pretty_generate(old_geo)}}
  })
end

def latest_geom_position_from(lat,lng)
  position = Hash.new
  
  position["type"] = "Feature"
  position["properties"] = {
    "marker-symbol" => "star",
    "marker-size" => "large",
    "desc" => "Stuart's last location",
    "time" => Time.now.to_s
  }
  position["geometry"] = {
    "type" => "Point",
    "coordinates" => [
      lng.to_f,
      lat.to_f
    ]
  }
  
  return position
end