nodemailer = require 'nodemailer'
MeshbluHttp = require 'meshblu-http'


class MailerService
  @processMessage: ({auth, config, message}, callback) ->
    meshblu = new MeshbluHttp auth
    {transportOptions, transporter} = config
    if transporter
      transportOptions = require("nodemailer-#{transporter}-transport")(transportOptions)

    nodemailer.createTransport(transportOptions).sendMail message, (err, info) =>
      meshblu.message devices: ['*'], result: {err,info}, {}, callback

module.exports = MailerService
