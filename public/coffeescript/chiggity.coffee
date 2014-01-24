loadLocations = ->
  onPosition = (pos) ->
    console.log pos
    showMap pos
    showLocations pos
  onError = (err) ->
    switch err.code
      when 1 then false
      when 2 then false
      when 3 then false
      else false
  options =
    enableHighAccuracy: false
  window.navigator.geolocation.getCurrentPosition onPosition, onError, options

showMap = (pos) ->
  map = L.map('map').setView([51.505, -0.09], 13)
  false

showLocations = (pos) ->
  false
  
$(document).ready ->
  if window.location.pathname == "/" and $('map').length
    loadLocations()
