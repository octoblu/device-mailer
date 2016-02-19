_ = require 'lodash'
CredentialDeviceManager = require './credential-device-manager'
UserCredentialDeviceManager = require './user-credential-device-manager'
MeshbluHttp = require 'meshblu-http'

class CredentialManager
  constructor: (options, meshbluConfig) ->
    @credentialDeviceManager = new CredentialDeviceManager _.defaults({}, options, type: 'channel-credentials:little-bits-cloud'), meshbluConfig
    @userCredentialDeviceManager = new UserCredentialDeviceManager _.defaults({}, options, type: 'device-credentials:little-bits-cloud'), meshbluConfig
    meshbluHttp = new MeshbluHttp meshbluConfig
    @privateKey = meshbluHttp.setPrivateKey meshbluConfig.privateKey
    @uuid = meshbluConfig.uuid

  findOrCreate: (userUuid, clientId, clientSecret, callback=->) =>
    clientSecret = @privateKey.encrypt clientSecret, 'base64'
    @credentialDeviceManager.findOrCreate clientId, @uuid, (error, device) =>
      return callback new Error 'Unable to find or create device' if error?

      @userCredentialDeviceManager.findOrCreate device.uuid, userUuid, @uuid, (error, userDevice) =>
        return callback new Error 'Unable to find or create device' if error?

        @credentialDeviceManager.addUserDevice device.uuid, userDevice.uuid
        @credentialDeviceManager.updateClientSecret device.uuid, clientSecret

        @credentialDeviceManager.generateToken device.uuid, (error, token) =>
          return callback new Error 'Unable to create token for device' if error?

          callback null, uuid: userDevice.uuid, creds: {uuid: device.uuid, token: token}

module.exports = CredentialManager
