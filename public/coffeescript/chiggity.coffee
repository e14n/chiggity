map = null

loadLocations = (bounds) ->
  n = bounds.getNorth()
  e = bounds.getEast()
  s = bounds.getSouth()
  w = bounds.getWest()
  url =  "/api/locations?box=#{w},#{s},#{e},#{n}"
  $.ajax {
    url: url,
    dataType: "json"
    success: (data, textStatus, jqXHR) ->
      console.log data
  }
  
$(document).ready ->

  if $('#map').length

    url = 'http://{s}.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.png'
    subs = ['otile1','otile2','otile3','otile4']
    attrib = '''Data, imagery and map information provided by
                <a href="http://open.mapquest.co.uk" target="_blank">MapQuest</a>,
                <a href="http://www.openstreetmap.org/" target="_blank">OpenStreetMap</a> and contributors.'''
    
    map = L.map 'map'

    layer = L.tileLayer(url, {
      attribution: attrib
      maxZoom: 18
      subdomains: subs
    })

    layer.addTo(map)

    self = null
    
    map.on 'locationfound', (levent) ->
      latlng = levent.latlng
      if self
        self.setLatLng latlng
        self.update()
      else
        self = L.marker latlng
        self.addTo map
      bounds = map.getBounds()
      loadLocations bounds
      false
    
    map.locate {setView: true, watch: true, maxZoom: 16}
  
