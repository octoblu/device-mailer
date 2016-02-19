dashdash = require 'dashdash'
MailerService = require '.'

ProtocolAdapter = require 'device-protocol-adapter-http'

adapter = new ProtocolAdapter {service: MailerService}

adapter.run()

process.on 'SIGTERM', =>
  console.log 'SIGTERM caught, exiting'
  adapter.stop =>
    process.exit 0
