require 'sinatra'
require 'twilio-ruby'
require 'json'
require 'octokit'

configure :production do
  require 'newrelic_rpm'
end

get '/' do
  "I'm alive!"
end

post '/sms-receive' do
  lat_lng_msg = params[:Body]
  lat, lng, msg = lat_lng_msg.split(',').map(&:strip)
  puts "INCOMING: #{lat_lng_msg}"

  current_location = latest_geom_position_from(lat,lng, msg)
  update_gist_location(current_location)

  twiml = Twilio::TwiML::Response.new do |r|
    r.Message "OK, I've got you at https://maps.google.com/maps/preview?q=#{lat},#{lng}"
  end
  twiml.text
end

def update_gist_location(position)
  client = Octokit::Client.new(:access_token => ENV['GH_TOKEN'])
  old_geo = JSON.load(File.open('lowe2015.geojson', 'r').read)
  old_geo["features"] << position

  client.edit_gist(ENV['GIST_ID'], {
    :files => {"lowe2015.geojson" => {"content" => JSON.pretty_generate(old_geo)}}
  })
end

def latest_geom_position_from(lat,lng, msg = nil)
  position = Hash.new

  position["type"] = "Feature"
  position["properties"] = {
    "marker-symbol" => "star",
    "marker-size" => "large",
    "Desc" => "Stuart's last location",
    "Time" => Time.now.to_s
  }
  position["geometry"] = {
    "type" => "Point",
    "coordinates" => [
      lng.to_f,
      lat.to_f
    ]
  }

  # Set the message property if there is one
  position["properties"]["Message"] = msg if msg

  puts "POSITION: #{position}"
  return position
end
