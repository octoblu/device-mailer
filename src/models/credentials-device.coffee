Device     = require './device'
UserDevice = require './user-device'
debug      = require('debug')('meshblu:device:credentials')

class CredentialsDevice extends Device

  updateClientSecret: ({clientSecret}, callback) =>
    debug 'updateClientSecret', {clientSecret}
    @meshbluHttp.update @uuid, clientSecret: clientSecret, callback

  addUserDevice: ({uuid, token}, callback) =>
    debug 'addUserDevice', {uuid, token}

    userDevice = new UserDevice {uuid, token}
    userDevice.addToWhitelist {@uuid}, (error) =>
      return callback error if error?
      @subscribeTo uuid: userDevice.uuid, callback

  subscribeTo: ({uuid}, callback) =>
    debug 'subscribeTo', {uuid}
    @meshbluHttp.createSubscription {
      subscriberUuid: @uuid
      emitterUuid:uuid
      type:'received'
    }, callback

module.exports = CredentialsDevice
