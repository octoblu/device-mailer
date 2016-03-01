_             = require 'lodash'
Server        = require './server'

class DeviceHttpProtocolAdapter
  constructor: ({@service}) ->
    @serverOptions =
      port           : process.env.PORT || 80
      service        : @service


  panic: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    server = new Server @serverOptions
    server.run (error) =>
      return @panic error if error?
      {address,port} = server.address()

module.exports = DeviceHttpProtocolAdapter
