_ = require 'lodash'
MeshbluHttp = require 'meshblu-http'
class CredentialDeviceManager
  constructor: ({@meshbluConfig}, dependencies={}) ->
    @meshbluHttp = new MeshbluHttp @meshbluConfig

  addUserDevice: (deviceUuid, userDeviceUuid, callback) =>
    @meshbluHttp.updateDangerously deviceUuid, $addToSet: {sendWhitelist: userDeviceUuid}, callback

  create: ({clientID, clientSecret}, callback) =>
    options = {clientID, clientSecret, owner: @meshbluConfig.uuid}
    @meshbluHttp.register options, (error, {uuid}) =>
      callback error, uuid

  updateOrCreate: ({clientID, clientSecret}, callback) =>
    @meshbluHttp.devices {clientID: clientID, owner: @meshbluConfig.uuid}, (error, result) =>
      return callback error if error? && error?.message != 'Devices not found'
      return @create {clientID, clientSecret}, callback if _.isEmpty result

      {uuid}= _.first result
      @updateClientSecret uuid, clientSecret, (error) =>
        callback error, uuid

  generateToken: (uuid, callback) =>
    meshbluHttp = new @MeshbluHttp @meshbluConfig
    meshbluHttp.generateAndStoreToken uuid, (error, result) =>
      return callback error if error?

      callback null, result.token

  updateClientSecret: (deviceUuid, clientSecret, callback) =>
    @meshbluHttp.update deviceUuid, clientSecret: clientSecret, callback

module.exports = CredentialDeviceManager
