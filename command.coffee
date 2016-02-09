dashdash = require 'dashdash'
MailerService = require '.'

ProtocolAdapter = require 'channel-device-protocol-adapter-http'

adapter = new ProtocolAdapter {service: MailerService}

adapter.run()
