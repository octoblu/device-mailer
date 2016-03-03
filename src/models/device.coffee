MeshbluHttp = require 'meshblu-http'

class Device
  constructor: ({@meshbluConfig}, dependencies={}) ->
    @meshbluConfig = @meshbluConfig.toJSON() if @meshbluConfig.toJSON?
    @meshbluHttp = new MeshbluHttp @meshbluConfig
    {@uuid, @token} = @meshbluConfig

  _userError: (message, code) =>
    error = new Error message
    error.code = code
    return error

module.exports = Device
