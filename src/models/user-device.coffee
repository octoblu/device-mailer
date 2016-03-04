_           = require 'lodash'
debug       = require('debug')('meshblu:device:user')
MeshbluHttp = require 'meshblu-http'
Device      = require './device'

class UserDevice extends Device
  addToWhitelist: ({uuid}, callback) =>
    debug 'addToWhitelist', {uuid}
    updateOptions =
      $addToSet:
        sendAsWhitelist: uuid
        receiveAsWhitelist: uuid

    @meshbluHttp.updateDangerously @uuid, updateOptions, callback

  updateOwner: ({owner}, callback) =>
    @meshbluHttp.updateDangerously @uuid, $set: {owner}, callback

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
    debug 'getDecryptOptions'
    @meshbluHttp.device @uuid, (error, device) =>
      debug 'getDecryptOptions', {error, device}
      return callback error if error?
      optionsEnvelope = @channelEncryption.decryptOptions device.encryptedOptions
      return @_userError "Options did not origininate from this device", 401 unless optionsEnvelope.uuid = @uuid
      callback null, optionsEnvelope.options

module.exports = UserDevice
