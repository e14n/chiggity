map = null

haversine = (lat1, lon1, lat2, lon2) ->
  
  rad = (flt) ->
    flt * Math.PI / 180
  
  R = 6371 # km
  dLat = rad(lat2-lat1)
  dLon = rad(lon2-lon1)
  lat1 = rad(lat1)
  lat2 = rad(lat2)

  a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2) 
  c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)) 
  d = R * c

loadLocations = (bounds, latlng) ->
  n = bounds.getNorth()
  e = bounds.getEast()
  s = bounds.getSouth()
  w = bounds.getWest()
  url =  "/api/locations?box=#{w},#{s},#{e},#{n}"
  $.ajax {
    url: url,
    dataType: "json"
    success: (locations, textStatus, jqXHR) ->
      _.each locations, (loc) ->
        loc.distance = haversine loc.position.latitude, loc.position.longitude, latlng.lat, latlng.lng
      locations.sort (a, b) ->
        if a.distance < b.distance
          -1
        else if b.distance < a.distance
          1
        else
          0
      updateList locations
  }

updateList = (locations) ->
  $("#locations").empty()
  _.each locations, (location) ->
    $("#locations").append("<div class='row'><div class='col-md-8'><h3>#{location.displayName} <small>#{location.chiggity_net.amenity}</small></h3></div> <div class='col-md-4 pull-right'>#{location.distance.toFixed(1)}km</div></div>")
  false
    
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
    area = null
    
    map.on 'locationfound', (levent) ->
      latlng = levent.latlng
      if self
        self.setLatLng latlng
        self.update()
      else
        self = L.marker latlng
        self.addTo map
      if area
        area.setLatLng latlng
        area.setRadius levent.accuracy
        area.update()
      else
        area = L.circle(latlng, levent.accuracy)
        area.addTo map
      
      bounds = map.getBounds()
      loadLocations bounds, latlng
      false

    map.on 'moveend', (levent) ->
      if self
        latlng = self.getLatLng()
        bounds = map.getBounds()
        loadLocations bounds, latlng
      false
        
    map.locate {setView: true, watch: true, maxZoom: 16}
  
