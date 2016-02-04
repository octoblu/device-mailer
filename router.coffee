MailerController = require './mailer-controller'

class Router
  route: (app) =>
    mailerController = new MailerController
    app.post '/message', mailerController.message

module.exports = Router
