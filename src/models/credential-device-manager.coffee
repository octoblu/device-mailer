_ = require 'lodash'

class CredentialDeviceManager
  constructor: (@options, @meshbluConfig, dependencies={}) ->
    @type = @options.type
    @logo = @options.logo
    @name = @options.name
    @messageSchemaUrl = @options.messageSchemaUrl
    @messageFormSchemaUrl = @options.messageFormSchemaUrl

    @MeshbluHttp = dependencies.MeshbluHttp ? require 'meshblu-http'

  addUserDevice: (deviceUuid, userDeviceUuid, callback=->) =>
    meshbluHttp = new @MeshbluHttp @meshbluConfig
    meshbluHttp.updateDangerously deviceUuid, $addToSet: {sendWhitelist: userDeviceUuid}, callback

  create: (params, callback=->) =>
    options =
      type: @type
      online: true
      messageSchemaUrl: @messageSchemaUrl
      messageFormSchemaUrl: @messageFormSchemaUrl
      logo: @logo
      name: @name
      owner: params.owner
      configureWhitelist: [params.owner]
      discoverWhitelist: [params.owner]
      clientID: params.clientID
      meshblu:
        messageForward: [params.owner]

    meshbluHttp = new @MeshbluHttp @meshbluConfig
    meshbluHttp.register options, (error, result) =>
      callback error, result

  findOrCreate: (clientID, owner, callback=->) =>
    meshbluHttp = new @MeshbluHttp @meshbluConfig
    meshbluHttp.devices type: @type, clientID: clientID, (error, result) =>
      return callback error if error? && error?.message != 'Devices not found'
      if _.isEmpty result?.devices
        return @create clientID: clientID, owner: owner, callback
      callback null, _.first result?.devices

  generateToken: (uuid, callback=->) =>
    meshbluHttp = new @MeshbluHttp @meshbluConfig
    meshbluHttp.generateAndStoreToken uuid, (error, result) =>
      return callback error if error?

      callback null, result.token

  updateClientSecret: (deviceUuid, clientSecret, callback=->) =>
    meshbluHttp = new @MeshbluHttp @meshbluConfig
    meshbluHttp.update deviceUuid, clientSecret: clientSecret

module.exports = CredentialDeviceManager
