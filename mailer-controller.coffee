MailerService = require './mailer-service'

class MailerController

  message: (req, res) =>
    config =
      auth: req.meshbluAuth
      options: req.meshbluAuth.device.options
      message: req.body

    MailerService.processMessage config, (error) =>
      return res.sendStatus(error.code || 500) if error?
      res.sendStatus 200

module.exports = MailerController
