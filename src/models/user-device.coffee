_           = require 'lodash'
debug       = require('debug')('meshblu:device:user')
MeshbluHttp = require 'meshblu-http'
Device      = require './device'

class UserDevice extends Device
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

module.exports = UserDevice
