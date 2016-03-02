_                 = require 'lodash'
nodemailer        = require 'nodemailer'
MeshbluHttp       = require 'meshblu-http'
MeshbluConfig     = require 'meshblu-config'

defaultUserDevice = require '../../data/device-user-config.json'

ChannelEncryption = require '../models/channel-encryption'
CredentialDeviceManager = require '../models/credential-device-manager'

class MailerService
  constructor: ({@meshbluConfig}) ->
    @channelEncryption = new ChannelEncryption {@meshbluConfig}
    @credentialDeviceManager = new CredentialDeviceManager {@meshbluConfig}

  onCreate: ({metadata, data}, callback) =>
    {auth} = metadata
    {owner} = data

    @createDevice {auth, owner}, callback

  onConfig: ({metadata, config}, callback) =>
    {options, encryptedOptions} = config
    {auth} = metadata
    return callback() unless options?

    @_encryptAndUpdate {auth, options}, (error) =>
      @getVerificationMessage {auth, options}, (error, message) =>
        return callback error if error?
        options =
          userDeviceUuid: config.uuid
          auth: auth
          options: options
          message: message

        @processMessage options, callback

  onReceived: ({metadata, message, config}, callback) =>
    {auth} = metadata
    {encryptedOptions} = config
    unless encryptedOptions?
      return meshblu.message {devices: ['*'], result: {error: 'encrypted options not found'}}, as: config.uuid, callback

    @channelEncryption.decryptOptions encryptedOptions, (error, options) =>
      options =
        userDeviceUuid: config.uuid
        auth: auth
        options: options
        message: message

      @processMessage options, callback

  _encryptAndUpdate: ({auth, options}, callback) =>
    return callback() if _.isEmpty options
    encryptedOptions = @channelEncryption.encryptOptions uuid: auth.uuid, options: options

    meshblu = new MeshbluHttp auth
    meshblu.updateDangerously auth.uuid, {$set: {encryptedOptions: encryptedOptions}, $unset: {options: true}}, callback

  createDevice: ({auth, owner}, callback) =>
    deviceData = @getUserDeviceData({auth, owner})

    meshblu = new MeshbluHttp auth
    meshblu.register deviceData, callback

  getUserDeviceData: ({auth, owner}) =>
    deviceData = _.cloneDeep defaultUserDevice
    return deviceData

  getVerificationMessage: ({auth, options}, callback) =>
    meshblu = new MeshbluHttp auth
    meshblu.generateAndStoreToken auth.uuid, (error, response) =>
      return callback error if error?
      code = encodeURIComponent(@channelEncryption.authToCode uuid: auth.uuid, token: response.token)

      message =
        to: options.auth.user
        from: options.auth.user
        subject: "Verify Email"
        text: "http://device-mailer.octoblu.dev/device/verify?code=#{code}&timestamp=#{Date.now()}"

      callback null, message

  processMessage: ({userDeviceUuid, auth, options, message}, callback) =>
    meshblu = new MeshbluHttp auth
    {transportOptions, transporter} = options
    if transporter
      transportOptions = require("nodemailer-#{transporter}-transport")(transportOptions)

    nodemailer.createTransport(transportOptions).sendMail message, (err, info) =>
      meshblu.message {devices: ['*'], result: {error: err?.message,info}}, as: userDeviceUuid, callback

  linkToCredentialsDevice: ({code, owner}, callback) =>
    {uuid, token, verified} = @channelEncryption.codeToAuth code
    return callback(@_userError 'Code could not be verified', 401) unless verified
    @_getEncryptedOptionsFromDevice {uuid, token}, (error, options) =>
      clientID = @_getClientID options
      clientSecret = @_getClientSecret options
      @credentialDeviceManager.updateOrCreate {clientID, clientSecret}, callback


  _getEncryptedOptionsFromDevice: ({uuid, token}, callback) =>
    meshbluJson = _.extend new MeshbluConfig().toJSON(), {uuid, token}
    meshblu = new MeshbluHttp meshbluJson
    meshblu.device uuid, (error, device) =>
      return callback error if error?
      optionsEnvelope = @channelEncryption.decryptOptions device.encryptedOptions
      return @_userError "Options did not origininate from this device", 401 unless optionsEnvelope.uuid = uuid
      callback null, optionsEnvelope.options

  _userError: (message, code) =>
    error = new Error message
    error.code = code
    return error

  _getClientID: (options) =>
    options.auth.user

  _getClientSecret: (options) =>
    options

module.exports = MailerService
