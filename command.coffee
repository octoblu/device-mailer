dashdash = require 'dashdash'
MailerService = require '.'

ProtocolAdapter = require 'device-protocol-adapter-http'

adapter = new ProtocolAdapter {service: MailerService}

adapter.run()
