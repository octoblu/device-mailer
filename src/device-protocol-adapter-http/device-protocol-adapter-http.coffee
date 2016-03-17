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

  run: (callback) =>
    @service.run (error)=>
      throw error if error?
      server = new Server @serverOptions
      server.run (error) =>
        return @panic error if error?
        {address,port} = server.address()
        callback()

  stop: (callback) =>
    callback()
    
module.exports = DeviceHttpProtocolAdapter
