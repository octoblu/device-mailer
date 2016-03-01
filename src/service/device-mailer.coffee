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
    return new NodeRSA keyBinary, 'pkcs1-private-der'
    
  onCreate: ({metadata, data}, callback) ->
    {auth} = metadata
    {owner} = data

    @createDevice {auth, owner}, callback

  onConfig: ({metadata, config}, callback) ->
    return @_encryptAndUpdate({metadata, config}, callback) if config.options?
    return callback new Error("No encrypted options: can't send verification email") unless config.encryptedOptions?

    @_decryptOptions config.encryptedOptions, (error, options) =>
      message = @getVerificationMessage options
      @onReceived {metadata, config, message}, callback

  onReceived: ({metadata, message, config}, callback) ->
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

  _encryptAndUpdate: ({metadata, config}, callback) ->
    {auth} = metadata
    options =
      userDeviceUuid: config.uuid
      auth: auth
      options: config.options

    @encryptOptions options, callback

  createDevice: ({auth, owner}, callback) ->
    deviceData = @getUserDeviceData({auth, owner})

    meshblu = new MeshbluHttp auth
    meshblu.register deviceData, callback

  getUserDeviceData: ({auth, owner}) =>
    deviceData = _.cloneDeep defaultUserDevice
    deviceData.owner = owner

    return deviceData

  getVerificationMessage: (options) =>
    return {
      to: options.auth.user
      from: options.auth.user
      subject: "U R verified!!"
      text: "That's pretty much it"
    }

  encryptOptions: ({userDeviceUuid, auth, options}, callback) ->
    return callback() if _.isEmpty options
    meshblu = new MeshbluHttp auth

    @_encryptOptions options, (error, encryptedOptions) =>
      return callback(error) if error?
      meshblu.updateDangerously userDeviceUuid, {$set: {encryptedOptions: encryptedOptions}, $unset: {options: true}}, callback

  processMessage: ({userDeviceUuid, auth, options, message}, callback) ->
    meshblu = new MeshbluHttp auth
    console.log('processing message:', {userDeviceUuid, auth, options, message})
    {transportOptions, transporter} = options
    if transporter
      transportOptions = require("nodemailer-#{transporter}-transport")(transportOptions)

    nodemailer.createTransport(transportOptions).sendMail message, (err, info) =>
      meshblu.message {devices: ['*'], result: {error: err?.message,info}}, as: userDeviceUuid, callback

  _encryptOptions: (options, callback) =>
    encryptedOptions = @key.encryptPrivate JSON.stringify options
    callback null, encryptedOptions

  _decryptOptions: (options, callback) =>
    decryptedOptions = JSON.parse @key.decrypt options
    callback null, decryptedOptions

module.exports = MailerService
