###
# routes.coffee
#
# Some more routes for the chiggity server
#
# Copyright 2014 E14N https://e14n.com/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###

request = require "request"
xml2js = require "xml2js"
async = require "async"
_ = require "underscore"

exports.locations = (req, res, next) ->
  
  box = req?.query?.box
  
  if !box?
    next new Error "No box argument"
    return
  
  [w, s, e, n] = box.split ","

  url = "http://open.mapquestapi.com/xapi/api/0.6/node[name=*][amenity=*][bbox=#{w},#{s},#{e},#{n}]"

  async.waterfall [
    (callback) ->
      request.get url, callback
    (response, body, callback) ->
      xml2js.parseString body, callback
  ], (err, result) ->
    if err
      next err
    else
      nodes = result.osm.node
      locations = _.map nodes, (node) ->
        console.dir node.tag
        name = _.find node.tag, (tag) -> return tag.$.k == "name"
        location =
          id: "tag:chiggity.net,2014:place:osm:#{node.$.id}"
          position:
            latitude: node.$.lat
            longitude: node.$.lon
          displayName: name?.$?.v
        location
      res.json locations
      
    
  
