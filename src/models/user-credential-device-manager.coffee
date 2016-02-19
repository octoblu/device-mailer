_ = require 'lodash'

class UserCredentialDeviceManager
  constructor: (options, @meshbluConfig, dependencies={}) ->
    {@type, @logo, @name, @messageSchemaUrl, @messageFormSchemaUrl} = options
    @MeshbluHttp = dependencies.MeshbluHttp ? require 'meshblu-http'

  create: (params, callback=->) =>
    options =
      type: @type
      online: true
      name: @name
      owner: params.owner
      parentDevice: params.parentUuid
      messageSchemaUrl: @messageSchemaUrl
      messageFormSchemaUrl: @messageFormSchemaUrl
      logo: @logo
      configureWhitelist: [params.owner]
      discoverWhitelist: [params.proxyUuid, params.owner]
      meshblu:
        messageForward: [params.parentUuid]

    meshbluHttp = new @MeshbluHttp @meshbluConfig
    meshbluHttp.register options, (error, result) =>
      callback error, result

  findOrCreate: (parentUuid, owner, proxyUuid, callback=->) =>
    meshbluHttp = new @MeshbluHttp @meshbluConfig
    meshbluHttp.devices type: @type, parentDevice: parentUuid, owner: owner, (error, result) =>
      return callback error if error? && error?.message != 'Devices not found'
      if _.isEmpty result?.devices
        return @create parentUuid: parentUuid, owner: owner, proxyUuid: proxyUuid, callback
      callback null, _.first result?.devices

module.exports = UserCredentialDeviceManager
