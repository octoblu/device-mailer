_                     = require 'lodash'
debug                 = require('debug')('meshblu:device:service')

MeshbluHttp           = require 'meshblu-http'
MeshbluConfig         = require 'meshblu-config'

CredentialsDeviceData = require '../../data/device-credentials-config'
CredentialsDevice     = require './credentials-device'

class ServiceDevice
  constructor: ({meshbluConfig}, dependencies={}) ->
    meshbluConfig   = new MeshbluConfig(meshbluConfig).toJSON()
    {@uuid, @token} = meshbluConfig
    @meshbluHttp    = new MeshbluHttp meshbluConfig

  createCredentialsDevice: ({clientID}, callback) =>
    options = _.extend {clientID, owner: @uuid}, CredentialsDeviceData
    @meshbluHttp.register options, (error, {uuid, token}={}) =>
      return callback error if error?
      callback error, new CredentialsDevice {uuid, token}

  findOrCreateCredentialsDevice: ({clientID}, callback) =>
    @meshbluHttp.devices {clientID: clientID, owner: @uuid}, (error, result) =>
      return callback error if error? && error?.message != 'Devices not found'
      return @createCredentialsDevice {clientID}, callback if _.isEmpty result

      {uuid} = _.first result
      @meshbluHttp.generateAndStoreToken uuid, (error, {token}={}) =>
        return callback error if error?
        return callback null, new CredentialsDevice {uuid, token}

  _userError: (message, code) =>
    error = new Error message
    error.code = code
    return error

module.exports = ServiceDevice
