_           = require 'lodash'
nodemailer  = require 'nodemailer'
MeshbluHttp = require 'meshblu-http'

AESCrypt    = require '../helpers/text-crypt'

class MailerService

  @onMessage: ({metadata, message, config}, callback) ->
    {auth} = metadata
    options =
      auth: auth
      encryptedOptions: config.encryptedOptions
      message: message

    MailerService.processMessage options, callback

  @onConfig: ({metadata, config}, callback) ->
    {auth} = metadata
    options =
      auth: auth
      options: config.options

    MailerService.encryptOptions options, callback


  @encryptOptions: ({auth, options}, callback) ->
    return callback() if _.isEmpty options
    meshblu = new MeshbluHttp auth

    MailerService._encryptOptions options, (error, encryptedOptions) =>
      return callback(error) if error?
      meshblu.updateDangerously auth.uuid, {$set: {encryptedOptions: encryptedOptions}, $unset: {options: true}}, callback

  @processMessage: ({auth, encryptedOptions, message}, callback) ->
    meshblu = new MeshbluHttp auth
    unless encryptedOptions?
      meshblu.message {devices: ['*'], result: {error: 'encrypted options not found'}}, {}, callback

    MailerService._decryptOptions encryptedOptions, (error, options) =>
      {transportOptions, transporter} = options
      if transporter
        transportOptions = require("nodemailer-#{transporter}-transport")(transportOptions)

      nodemailer.createTransport(transportOptions).sendMail message, (err, info) =>
        meshblu.message {devices: ['*'], result: {error: err?.message,info}}, {}, callback

  @_encryptOptions: (options, callback) =>
    encryptedOptions = AESCrypt.encrypt JSON.stringify options
    callback null, encryptedOptions

  @_decryptOptions: (options, callback) =>
    decryptedOptions = JSON.parse AESCrypt.decrypt options
    callback null, decryptedOptions

module.exports = MailerService
