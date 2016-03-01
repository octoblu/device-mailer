_                 = require 'lodash'
nodemailer        = require 'nodemailer'
MeshbluHttp       = require 'meshblu-http'

NodeRSA           = require 'node-rsa'
defaultUserDevice = require '../../data/device-user-config.json'
CredentialManager = require '../models/credential-manager'

class MailerService
  constructor: ({@meshbluConfig}) ->
    throw new Error('Private key not found!') unless @meshbluConfig.privateKey?
    @key = @getPrivateKey @meshbluConfig.privateKey

  getPrivateKey: (keyString) =>
    keyBinary = new Buffer(keyString, 'base64')
    return new NodeRSA keyBinary, 'pkcs1-der'

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

    @_decryptOptions encryptedOptions, (error, options) =>
      options =
        userDeviceUuid: config.uuid
        auth: auth
        options: options
        message: message

      @processMessage options, callback

  _encryptAndUpdate: ({auth, options}, callback) =>
    return callback() if _.isEmpty options
    encryptedOptions = @_encryptOptions options

    meshblu = new MeshbluHttp auth
    meshblu.updateDangerously auth.uuid, {$set: {encryptedOptions: encryptedOptions}, $unset: {options: true}}, callback

  createDevice: ({auth, owner}, callback) =>
    deviceData = @getUserDeviceData({auth, owner})

    meshblu = new MeshbluHttp auth
    meshblu.register deviceData, callback

  getUserDeviceData: ({auth, owner}) =>
    deviceData = _.cloneDeep defaultUserDevice
    deviceData.owner = owner

    return deviceData

  getVerificationMessage: ({auth, options}, callback) =>
    meshblu = new MeshbluHttp auth
    meshblu.generateAndStoreToken auth.uuid, (error, response) =>
      return callback error if error?
      code = @_authToCode uuid: auth.uuid, token: response.token
      message =
        to: options.auth.user
        from: options.auth.user
        subject: "Verify Email"
        text: "http://device-mailer.octoblu.dev/device/verify?code=#{code}"

      callback null, message

  processMessage: ({userDeviceUuid, auth, options, message}, callback) =>
    meshblu = new MeshbluHttp auth
    {transportOptions, transporter} = options
    if transporter
      transportOptions = require("nodemailer-#{transporter}-transport")(transportOptions)

    nodemailer.createTransport(transportOptions).sendMail message, (err, info) =>
      meshblu.message {devices: ['*'], result: {error: err?.message,info}}, as: userDeviceUuid, callback

  _authToCode: ({uuid, token}) =>
    newAuth = "#{uuid}:#{token}"
    verifier =
      auth: newAuth
      signature: @_sign newAuth

    return encodeURIComponent(new Buffer(JSON.stringify(verifier)).toString('base64'))

  _codeToAuth: (code) =>
    {auth, signature} = JSON.parse(new Buffer(code, 'base64').toString())
    verified = @_verify auth, signature
    [uuid, token] = auth.split ':'

    return {uuid, token, verified}

  _encryptOptions: (options) =>
    @key.encrypt(JSON.stringify options).toString 'base64'

  _decryptOptions: (options) =>
    decryptedOptions = JSON.parse @key.decrypt(options)

  _sign: (options) =>
    optionsBuffer = new Buffer(options)
    @key.sign optionsBuffer

  _verify: (options, signature) =>
    optionsBuffer = new Buffer options
    signatureBuffer = new Buffer signature, 'base64'

    @key.verify optionsBuffer, signatureBuffer

module.exports = MailerService
