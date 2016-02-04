_             = require 'lodash'
Server        = require './server'

class Command
  constructor: ->
    @serverOptions =
      port                 : process.env.PORT || 80
      disableLogging       : process.env.DISABLE_LOGGING == "true"


  panic: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    server = new Server @serverOptions, {}
    server.run (error) =>
      return @panic error if error?

      {address,port} = server.address()
      console.log "Server listening on #{address}:#{port}"

command = new Command()
command.run()
