debug = require('debug')('meshblu:device-protocol-adapter-http')
MeshbluHttp = require 'meshblu-http'
url = require 'url'
_ = require 'lodash'

class CredentialsController
  constructor: ({@service, @serviceUrl}) ->

  authenticate: (req, res) =>
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
          protocol: req.meshbluAuth.protocol
          hostname: req.meshbluAuth.host
          port: req.meshbluAuth.port
          callbackURL: "#{@serviceUrl}/device/configured"

      res.redirect editUrl

  verify: (req, res) =>
    @service.linkToCredentialsDevice {code: req.query.code, owner: req.meshbluAuth.uuid}, (error, data) =>
      res.status(error.code || 500).send(error.message) if error?
      res.status(200).send data

module.exports = CredentialsController
