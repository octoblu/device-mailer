Device     = require 'device'
UserDevice = require 'user-device'

class CredentialsDevice extends Device
  
  updateClientSecret: ({clientSecret}, callback) =>
    @meshbluHttp.update deviceUuid, clientSecret: clientSecret, callback

  addUserDevice: ({uuid, token}) =>
    userDevice = new UserDevice({uuid, token})
    userDevice.addToWhitelist @uuid, (error) =>
      return callback error if error?
      @subscribeTo uuid: userDevice.uuid, callback

  subscribeTo: ({uuid}, callback) =>
    @meshbluHttp.createSubscription {
      subscriberUuid: @meshbluConfig.uuid
      emitterUuid:uuid
      type:'received'
    }, callback



module.exports = CredentialsDevice
