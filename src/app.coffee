###
# app.coffee
#
# Main entry point for the chiggity checkin server
#
# Copyright 2013 E14N https://e14n.com/
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

fs = require "fs"
path = require "path"
_ = require "underscore"
PumpIOClient = require "pump.io-client-app"

defaults =
  hostname: "localhost"
  port: process.env.PORT || 80
  driver: "memory"
  params: {}
  name: "Chiggity"
  description: "The checkin server for the pump network"
  views: path.join(__dirname, "..", "views")
  static: path.join(__dirname, "..", "public")

if fs.existsSync "/etc/chiggity.json"
  config = JSON.parse fs.readFileSync "/etc/chiggity.json"
  config = _.defaults config, defaults
else
  config = defaults

config.address = config.address or process.env.IP or config.hostname

app = new PumpIOClient config

app.run (err) ->
  if err
    console.error err
    process.exit -1
  else
    console.log "Chiggity listening on #{config.hostname}:#{config.port}"
