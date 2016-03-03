_ = require 'lodash'
MeshbluHttp = require 'meshblu-http'

class UserDevice
  constructor: ({@meshbluConfig}, dependencies={}) ->
    @meshbluConfig = @meshbluConfig.toJSON() if @meshbluConfig.toJSON?
    @meshbluHttp = new MeshbluHttp @meshbluConfig
    {@uuid, @token} = @meshbluConfig

  addToWhitelist: ({uuid}, callback) =>
    updateOptions =
      $addToSet:
        sendAsWhitelist: credentialsDeviceUuid
        receiveAsWhitelist: credentialsDeviceUuid

    @meshbluHttp.updateDangerously uuid, updateOptions, callback

  decryptOptions: (callback) =>
    @meshbluHttp.device uuid, (error, device) =>
      return callback error if error?
      optionsEnvelope = @channelEncryption.decryptOptions device.encryptedOptions
      return @_userError "Options did not origininate from this device", 401 unless optionsEnvelope.uuid = uuid
      callback null, optionsEnvelope.options

module.exports = UserDevice
