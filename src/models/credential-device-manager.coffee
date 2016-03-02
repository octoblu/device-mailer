_ = require 'lodash'
MeshbluHttp = require 'meshblu-http'
class CredentialDeviceManager
  constructor: ({@meshbluConfig}, dependencies={}) ->
    @meshbluHttp = new MeshbluHttp @meshbluConfig

  addUserDevice: (deviceUuid, userDeviceUuid, callback=->) =>
    @meshbluHttp.updateDangerously deviceUuid, $addToSet: {sendWhitelist: userDeviceUuid}, callback

  create: ({clientID}, callback=->) =>
    options = {clientID, owner: @meshbluConfig.uuid}
    @meshbluHttp.register options, (error, result) =>
      callback error, result

  findOrCreate: ({clientID}, callback=->) =>
    @meshbluHttp.devices {clientID: clientID, owner: @meshbluConfig.uuid}, (error, result) =>
      return callback error if error? && error?.message != 'Devices not found'
      return @create {clientID}, callback if _.isEmpty result

      callback null, _.first result

  generateToken: (uuid, callback=->) =>
    meshbluHttp = new @MeshbluHttp @meshbluConfig
    meshbluHttp.generateAndStoreToken uuid, (error, result) =>
      return callback error if error?

      callback null, result.token

  updateClientSecret: (deviceUuid, clientSecret, callback=->) =>
    meshbluHttp = new @MeshbluHttp @meshbluConfig
    meshbluHttp.update deviceUuid, clientSecret: clientSecret

module.exports = CredentialDeviceManager
