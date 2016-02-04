MailerService = require './mailer-service'

class MailerController

  message: (req, res) =>
    options =
      auth: req.meshbluAuth
      config: req.meshbluAuth.device.config
      message: req.body

    MailerService.processMessage options, (error) =>
      return res.sendStatus(error.code || 500) if error?
      res.sendStatus 200

module.exports = MailerController
