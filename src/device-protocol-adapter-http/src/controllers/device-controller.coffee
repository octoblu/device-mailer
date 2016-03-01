debug = require('debug')('meshblu:device-protocol-adapter-http')
MeshbluHttp = require 'meshblu-http'
_ = require 'lodash'

class DeviceController
  constructor: ({@service}) ->

  getUserDeviceConfig: (req, callback) =>
    meshblu = new MeshbluHttp req.meshbluAuth
    userDeviceUuid = req.meshbluAuth.uuid
    userDeviceUuid = _.first req.body.forwardedFor unless _.isEmpty req.body.forwardedFor

    meshblu.device userDeviceUuid, (error, userDevice) =>
      return callback error if error?
      callback null, userDevice

  getReceivedEnvelope: (req, callback) =>
    message = req.body
    message = req.body.payload if req.body.payload?

    @getUserDeviceConfig req, (error, userDevice) =>
      return callback error if error?
      envelope =
        metadata:
          auth: req.meshbluAuth
        message: message.message
        config: userDevice

      debug 'receivedEnvelope', envelope
      callback null, envelope

  getConfigEnvelope: (req, callback) =>
    @getUserDeviceConfig req, (error, userDevice) =>
      debug 'userDevice', userDevice
      return callback error if error?
      envelope =
        metadata:
          auth: req.meshbluAuth
        config: userDevice

      # debug 'configEnvelope', JSON.stringify envelope,null,2
      callback null, envelope

  config: (req, res) =>
    debug 'config', req.body
    @getConfigEnvelope req, (error, envelope) =>
      return res.sendStatus(error.code || 500) if error?

      @service.onConfig envelope, =>
        return res.sendStatus(error.code || 500) if error?
        res.sendStatus 200

  received: (req, res) =>
    debug 'received', req.body
    @getReceivedEnvelope req, (error, envelope) =>
      return res.sendStatus(error.code || 500) if error?

      @service.onReceived envelope, =>
        return res.sendStatus(error.code || 500) if error?
        res.sendStatus 200

module.exports = DeviceController
