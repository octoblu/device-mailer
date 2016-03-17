dashdash = require 'dashdash'
MailerService = require '.'
MeshbluConfig = require 'meshblu-config'

ProtocolAdapter = require './src/device-protocol-adapter-http'

service = new MailerService(
  meshbluConfig: new MeshbluConfig().toJSON()
  serviceUrl: process.env.SERVICE_URL
)

adapter = new ProtocolAdapter {service}
adapter.run()

process.on 'SIGTERM', =>
  console.log 'SIGTERM caught, exiting'
  adapter.stop =>
    process.exit 0
