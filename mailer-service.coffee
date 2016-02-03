nodemailer = require 'nodemailer'
MeshbluWebsocket = require 'meshblu-websocket'
MeshbluConfig = require 'meshblu-config'

meshbluConfig = (new MeshbluConfig).toJSON()
meshblu = new MeshbluWebsocket meshbluConfig

meshbluConnect = (err) =>
  if err
    console.error err.message
    return

  meshblu.on 'error', (err) =>
    console.error err.message if err?
    meshblu.close()
    meshblu.connect meshbluConnect

  meshblu.subscribe uuid: meshbluConfig.uuid, types: ["received"]

  meshblu.on 'message', (data) =>
    return if !data?

    transportOptions = data.transportOptions
    if data.transporter
      transportOptions = require("nodemailer-#{data.transporter}-transport")(transportOptions)

    nodemailer.createTransport(transportOptions).sendMail data.message, (err, info) =>
      meshblu.message devices: [data.fromUuid], result: {err, info}

meshblu.connect meshbluConnect
