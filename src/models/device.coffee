debug = require('debug')('meshblu:device')

MeshbluHttp       = require 'meshblu-http'
MeshbluConfig     = require 'meshblu-config'
ChannelEncryption = require './channel-encryption'

class Device
  constructor: ({@uuid, @token}, dependencies={}) ->
    meshbluConfig      = new MeshbluConfig({@uuid, @token}).toJSON()
    @meshbluHttp       = new MeshbluHttp meshbluConfig
    @channelEncryption = new ChannelEncryption meshbluConfig

  _userError: (message, code) =>
    error = new Error message
    error.code = code
    return error

module.exports = Device
