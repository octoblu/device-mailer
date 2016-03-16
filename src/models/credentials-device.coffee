MeshbluHttp       = require 'meshblu-http'
MeshbluConfig     = require 'meshblu-config'

UserDevice        = require './user-device'
ChannelEncryption = require '../models/channel-encryption'

class CredentialsDevice
  constructor: ({meshbluConfig}, dependencies={}) ->
    meshbluConfig      = new MeshbluConfig(meshbluConfig).toJSON()

    {@uuid, @token}    = meshbluConfig
    @meshbluHttp       = new MeshbluHttp meshbluConfig
    @channelEncryption = new ChannelEncryption meshbluConfig

  setClientSecret: ({clientSecret}, callback) =>
    clientSecret = @channelEncryption.encryptOptions clientSecret
    @meshbluHttp.update @uuid, clientSecret: clientSecret, callback

  getClientSecret: (callback) =>
    @meshbluHttp.whoami (error, device) =>
      return callback error if error?
      clientSecret = @channelEncryption.decryptOptions device.clientSecret
      callback null, clientSecret

  addUserDevice: ({uuid, token, owner}, callback) =>
    userDevice = new UserDevice meshbluConfig: {uuid, token}
    userDevice.linkToCredentialsAndOwner credentialsUuid: @uuid, owner: owner, (error) =>
      return callback error if error?
      @subscribeTo uuid: userDevice.uuid, callback

  subscribeTo: ({uuid}, callback) =>
    @meshbluHttp.createSubscription {
      subscriberUuid: @uuid
      emitterUuid:uuid
      type:'received'
    }, callback

  getUserDevices: (callback) =>
    @meshbluHttp.subscriptions @uuid, callback

  _userError: (message, code) =>
    error = new Error message
    error.code = code
    return error

module.exports = CredentialsDevice
