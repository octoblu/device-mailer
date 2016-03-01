_           = require 'lodash'
nodemailer  = require 'nodemailer'
MeshbluHttp = require 'meshblu-http'

AESCrypt    = require '../helpers/text-crypt'

defaultUserDevice = require '../../data/device-user-config.json'
CredentialManager = require '../models/credential-manager'

class MailerService

  @onCreate: ({metadata, data}, callback) ->
    {auth} = metadata
    {owner} = data

    MailerService.createDevice {auth, owner}, callback

  @onConfig: ({metadata, config}, callback) ->
    return MailerService._encryptAndUpdate({metadata, config}, callback) if config.options?
    return callback new Error("No encrypted options: can't send verification email") unless config.encryptedOptions?
    MailerService._decryptOptions config.encryptedOptions, (error, options) =>
      message = MailerService.getVerificationMessage options
      MailerService.onReceived {metadata, config, message}, callback

  @onReceived: ({metadata, message, config}, callback) ->
    {auth} = metadata
    {encryptedOptions} = config
    unless encryptedOptions?
      return meshblu.message {devices: ['*'], result: {error: 'encrypted options not found'}}, as: userDeviceUuid, callback

    MailerService._decryptOptions encryptedOptions, (error, options) =>
      options =
        userDeviceUuid: config.uuid
        auth: auth
        options: options
        message: message

      MailerService.processMessage options, callback

  @_encryptAndUpdate: ({metadata, config}, callback) ->
    {auth} = metadata
    options =
      userDeviceUuid: config.uuid
      auth: auth
      options: config.options

    MailerService.encryptOptions options, callback

  @createDevice: ({auth, owner}, callback) ->
    deviceData = MailerService.getUserDeviceData({auth, owner})

    meshblu = new MeshbluHttp auth
    meshblu.register deviceData, callback

  @getUserDeviceData: ({auth, owner}) =>
    deviceData = _.cloneDeep defaultUserDevice
    deviceData.owner = owner

    return deviceData

  @getVerificationMessage: (options) =>
    return {
      to: options.auth.user
      from: options.auth.user
      subject: "U R verified!!"
      text: "That's pretty much it"
    }

  @encryptOptions: ({userDeviceUuid, auth, options}, callback) ->
    return callback() if _.isEmpty options
    meshblu = new MeshbluHttp auth

    MailerService._encryptOptions options, (error, encryptedOptions) =>
      return callback(error) if error?
      meshblu.updateDangerously userDeviceUuid, {$set: {encryptedOptions: encryptedOptions}, $unset: {options: true}}, callback

  @processMessage: ({userDeviceUuid, auth, options, message}, callback) ->
    meshblu = new MeshbluHttp auth
    console.log('processing message:', {userDeviceUuid, auth, options, message})
    {transportOptions, transporter} = options
    if transporter
      transportOptions = require("nodemailer-#{transporter}-transport")(transportOptions)

    nodemailer.createTransport(transportOptions).sendMail message, (err, info) =>
      meshblu.message {devices: ['*'], result: {error: err?.message,info}}, as: userDeviceUuid, callback

  @_encryptOptions: (options, callback) =>
    encryptedOptions = AESCrypt.encrypt JSON.stringify options
    callback null, encryptedOptions

  @_decryptOptions: (options, callback) =>
    decryptedOptions = JSON.parse AESCrypt.decrypt options
    callback null, decryptedOptions

module.exports = MailerService
