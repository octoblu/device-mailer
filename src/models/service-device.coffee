_                     = require 'lodash'
fs                    = require 'fs'
debug                 = require('debug')('meshblu:device:service')

MeshbluHttp           = require 'meshblu-http'
MeshbluConfig         = require 'meshblu-config'

CredentialsDeviceData = require '../../data/device-credentials-config'
CredentialsDevice     = require './credentials-device'
ChannelEncryption     = require './channel-encryption'

class ServiceDevice
  constructor: ({meshbluConfig, @serviceUrl}, dependencies={}) ->
    meshbluConfig            = new MeshbluConfig(meshbluConfig).toJSON()
    {@uuid, @token}          = meshbluConfig
    @meshblu                 = new MeshbluHttp meshbluConfig
    @channelEncryption       = new ChannelEncryption meshbluConfig
    @userDeviceConfig        = @_getUserDeviceConfig {@serviceUrl}
    @credentialsDeviceConfig = @_getCredentialsDeviceConfig {owner: @uuid, @serviceUrl}
    @serviceDeviceConfig     = @_getServiceDeviceConfig {@serviceUrl}

  update: (callback) =>
    @meshblu.update @uuid, @serviceDeviceConfig, callback

  createCredentialsDevice: ({clientID}, callback) =>
    deviceConfig          = _.cloneDeep @credentialsDeviceConfig
    deviceConfig.clientID = clientID

    @meshblu.register deviceConfig, (error, {uuid, token}={}) =>
      return callback error if error?
      callback error, new CredentialsDevice meshbluConfig: {uuid, token}

  createUserDevice: ( options, callback) =>
    deviceOptions = _.extend {}, options, @userDeviceConfig
    @meshblu.register @userDeviceConfig, callback

  findOrCreateCredentialsDevice: ({clientID}, callback) =>
    @meshblu.devices {clientID: clientID, owner: @uuid}, (error, result) =>
      return callback error if error? && error?.message != 'Devices not found'
      return @createCredentialsDevice {clientID}, callback if _.isEmpty result

      {uuid} = _.first result
      @meshblu.generateAndStoreToken uuid, (error, {token}={}) =>
        return callback error if error?
        return callback null, new CredentialsDevice meshbluConfig: {uuid, token}

  _getUserDeviceConfig: (templateOptions) =>
    return @_templateDevice './data/device-user-config.json', templateOptions

  _getCredentialsDeviceConfig: (templateOptions) =>
    return @_templateDevice './data/device-credentials-config.json', templateOptions

  _getServiceDeviceConfig: (templateOptions) =>
    publicKey = @channelEncryption.getPublicKey()
    templateOptions = _.extend {publicKey}, templateOptions
    return @_templateDevice './data/device-service-config.json', templateOptions

  _templateDevice: (templatePath, templateOptions) =>
    deviceTemplate = fs.readFileSync templatePath, 'utf8'
    return JSON.parse _.template(deviceTemplate)(templateOptions)

  _userError: (message, code) =>
    error = new Error message
    error.code = code
    return error

module.exports = ServiceDevice
