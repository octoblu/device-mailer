MailerService = require '../services/mailer-service'

class MailerController

  encryptOptions: (req, res) =>
    config =
      auth: req.meshbluAuth
      options: req.meshbluAuth.device.options

    MailerService.encryptOptions config, (error) =>
      return res.sendStatus(error.code || 500) if error?
      res.sendStatus 200

  message: (req, res) =>
    config =
      auth: req.meshbluAuth
      encryptedOptions: req.meshbluAuth.device.encryptedOptions
      message: req.body?.payload

    MailerService.processMessage config, (error) =>
      return res.sendStatus(error.code || 500) if error?
      res.sendStatus 200

module.exports = MailerController
