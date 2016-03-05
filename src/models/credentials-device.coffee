Device     = require './device'
UserDevice = require './user-device'

class CredentialsDevice extends Device
  setClientSecret: ({clientSecret}, callback) =>
    clientSecret = @channelEncryption.encryptOptions clientSecret
    @meshbluHttp.update @uuid, clientSecret: clientSecret, callback

  getClientSecret: (callback) =>
    @meshbluHttp.whoami (error, device) =>
      return callback error if error?
      clientSecret = @channelEncryption.decryptOptions device.clientSecret
      callback null, clientSecret

  addUserDevice: ({uuid, token, owner}, callback) =>
    userDevice = new UserDevice {uuid, token}
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

module.exports = CredentialsDevice
