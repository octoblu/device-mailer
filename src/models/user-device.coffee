_                 = require 'lodash'
debug             = require('debug')('meshblu:device:user')

MeshbluHttp       = require 'meshblu-http'
MeshbluConfig     = require 'meshblu-config'
ChannelEncryption = require '../models/channel-encryption'


class UserDevice
  constructor: ({meshbluConfig}, dependencies={}) ->
    throw new Error("Device must be constructed with credentials. Otherwise Bad Things will happen.") unless meshbluConfig?
    meshbluConfig      = new MeshbluConfig(meshbluConfig).toJSON()

    {@uuid, @token}    = meshbluConfig
    @meshbluHttp       = new MeshbluHttp meshbluConfig
    @channelEncryption = new ChannelEncryption meshbluConfig

  linkToCredentialsAndOwner: ({owner, credentialsUuid}, callback) =>
    updateOptions =
      $addToSet:
        sendAsWhitelist: credentialsUuid
        receiveAsWhitelist: credentialsUuid
      $set:
        owner: owner
      $unset:
        encryptedOptions : true

    @meshbluHttp.updateDangerously @uuid, updateOptions, (error) =>
      return callback error if error?
      @meshbluHttp.revokeToken @uuid, @token, callback

  setEncryptedOptions: ({options}, callback) =>
    return callback() if _.isEmpty options
    encryptedOptions = @channelEncryption.encryptOptions {@uuid, options}
    updateOptions =
      $set:
        encryptedOptions: encryptedOptions
        lastEncrypted: Date.now()
      $unset:
        options: true

    @meshbluHttp.updateDangerously @uuid, updateOptions, callback

  getDecryptedOptions: (callback) =>
    @meshbluHttp.device @uuid, (error, device) =>
      return callback error if error?
      optionsEnvelope = @channelEncryption.decryptOptions device.encryptedOptions
      return @_userError "Options did not origininate from this device", 401 unless optionsEnvelope.uuid = @uuid
      callback null, optionsEnvelope.options

  _userError: (message, code) =>
    error = new Error message
    error.code = code
    return error


module.exports = UserDevice
