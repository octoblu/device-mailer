debug = require('debug')('meshblu:device-protocol-adapter-http')
MeshbluHttp = require 'meshblu-http'
url = require 'url'
_ = require 'lodash'

class CredentialsController
  constructor: ({@service}) ->

  authenticate: (req, res) =>
    console.log {user: req.user, cookie: req.cookies}
    res.cookie('meshblu_auth_bearer', req.user.bearerToken)
    res.redirect '/device/authorize'

  authorize: (req, res) =>
    createEnvelope =
      metadata:
        auth: req.meshbluAuth
      data:
        owner: req.meshbluAuth.uuid

    @service.onCreate createEnvelope, (error, device) =>
      return res.status(error.code || 500).send(error.message) if error?

      editUrl = url.format
        host: "device-editor-octoblu.octoblu.dev/#{device.uuid}"
        query:
          token: device.token
          server: req.meshbluAuth.host
          port: req.meshbluAuth.port
          callbackURL: "http://device-mailer.octoblu.dev/device/configured"

      res.redirect editUrl

  authorized: (req, res) =>
    throw new Error('Implement authorized plz')

  verifyConfiguration: (req, res) =>
    console.log "Hi. I'm verifying your configuration."
    configEnvelope =
      metadata:
        auth: req.meshbluAuth
      config: req.body

    console.log {configEnvelope}

    @service.onVerifyConfiguration configEnvelope, (error) =>
      return res.status(error.code || 500).send error.message if error?
      res.sendStatus 200

module.exports = CredentialsController
