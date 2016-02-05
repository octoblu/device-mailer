MailerController = require './src/controllers/mailer-controller'

class Router
  route: (app) =>
    mailerController = new MailerController
    app.post '/message', mailerController.message
    app.post '/encrypt-options', mailerController.encryptOptions

module.exports = Router
