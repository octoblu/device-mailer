MailerController = require './mailer-controller'

class Router
  route: (app) =>
    mailerController = new MailerController
    app.post '/messages', mailerController.message

module.exports = Router
