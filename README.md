RTW Location
===========

Tracking Stuart on his recreation of Thomas Stevens 1884 around the world bike ride: http://strudel.org.uk/RTWbike by receiving an SMS from Stuart and updating [this map](https://gist.github.com/arfon/11101663).

### Why?

Stuart has an old phone and a GPS with him so I figured we should make a SMS service he can post his lat, long and an optional message to that would set his position on a map for all to see.

### How?

Pretty simple really:

- Sinatra application hooked up to Twilio that can [receive](https://github.com/arfon/rtwlocation/blob/master/rtwlocation.rb#L14-L25) an inbound SMS via the [Twilio API](https://www.twilio.com/docs/quickstart/ruby/sms/hello-monkey).
- [Parse](https://github.com/arfon/rtwlocation/blob/master/rtwlocation.rb#L15) the incoming SMS and [make a position marker](https://github.com/arfon/rtwlocation/blob/master/rtwlocation.rb#L37-L58) for the geojson
- [Append](https://github.com/arfon/rtwlocation/blob/master/rtwlocation.rb#L29-L30) this new marker to a (local) copy of the [same geojson file](https://github.com/arfon/rtwlocation/blob/master/lowe2014.geojson) that's in the [Gist](https://gist.github.com/arfon/11101663)
- [Commit the new file](https://github.com/arfon/rtwlocation/blob/master/rtwlocation.rb#L32-L34) with the current location using [Octokit](http://octokit.github.io/octokit.rb/)
