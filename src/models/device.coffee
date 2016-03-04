MeshbluHttp = require 'meshblu-http'
ChannelEncryption = require './channel-encryption'
debug = require('debug')('meshblu:device')

class Device
  constructor: ({@meshbluConfig}, dependencies={}) ->
    @meshbluConfig     = @meshbluConfig.toJSON() if @meshbluConfig.toJSON?
    {@uuid, @token}    = @meshbluConfig
    @meshbluHttp       = new MeshbluHttp @meshbluConfig
    @channelEncryption = new ChannelEncryption {@meshbluConfig}
    debug "instantiated device #{@uuid} : #{@token}"

  _userError: (message, code) =>
    error = new Error message
    error.code = code
    return error

module.exports = Device
