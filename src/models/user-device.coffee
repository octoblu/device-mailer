_           = require 'lodash'
debug       = require('debug')('meshblu:device:user')
MeshbluHttp = require 'meshblu-http'
Device      = require './device'

class UserDevice extends Device
  addToWhitelist: ({uuid}, callback) =>
    debug 'addToWhitelist', {uuid}
    updateOptions =
      $addToSet:
        sendAsWhitelist: credentialsDeviceUuid
        receiveAsWhitelist: credentialsDeviceUuid

    @meshbluHttp.updateDangerously uuid, updateOptions, callback

  setEncryptedOptions: ({options}, callback) =>
    return callback() if _.isEmpty options
    encryptedOptions = @channelEncryption.encryptOptions {@uuid, options}
    @meshbluHttp.updateDangerously @uuid, {$set: {encryptedOptions: encryptedOptions}, $unset: {options: true}}, callback

  getDecryptedOptions: (callback) =>
    debug 'decryptOptions'
    @meshbluHttp.device uuid, (error, device) =>
      return callback error if error?
      optionsEnvelope = @channelEncryption.decryptOptions device.encryptedOptions
      return @_userError "Options did not origininate from this device", 401 unless optionsEnvelope.uuid = uuid
      callback null, optionsEnvelope.options

module.exports = UserDevice
