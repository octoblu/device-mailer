url                   = require 'url'
passport              = require 'passport'
MeshbluAuth           = require 'express-meshblu-auth'
DeviceController      = require './src/controllers/device-controller'
CredentialsController = require './src/controllers/credentials-controller'
OctobluStrategy       = require 'passport-octoblu'

class Router
  constructor: ({service, @meshbluConfig}, dependencies={}) ->
    @deviceController      = new DeviceController {service}
    @credentialsController = new CredentialsController {service}

  route: (app) =>
    app.use passport.initialize()
    app.use passport.session()
    @setupOctobluOauth clientID: 'oauth-provider-uuid', clientSecret: 'some-random-token'

    app.get '/octoblu/authenticate', passport.authenticate('octoblu'), @credentialsController.authenticate

    meshbluAuth = MeshbluAuth @meshbluConfig, errorCallback: (error, {req, res}) =>
      res.redirect '/octoblu/authenticate'

    app.use meshbluAuth
    app.get '/device/authorize', @credentialsController.authorize

    app.get '/device/verify', @credentialsController.verify

    app.get '/device/configured', (req, res) =>
      res.send('device configured. please check your email to confirm your credentials')

    app.post '/events/received', @deviceController.received
    app.post '/events/config', @deviceController.config

    app.get '/', (req, res) => res.redirect '/device/authorize'
    
  setupOctobluOauth: ({clientID, clientSecret}) =>
    octobluStrategyConfig =
      clientID: clientID
      authorizationURL: 'http://oauth.octoblu.dev/authorize'
      tokenURL: 'http://oauth.octoblu.dev/access_token'
      clientSecret: clientSecret
      callbackURL: 'http://device-mailer.octoblu.dev/octoblu/authenticate'
      passReqToCallback: true

    passport.use new OctobluStrategy octobluStrategyConfig, (req, bearerToken, secret, {uuid}, next) =>
      next null, {uuid, bearerToken}

    passport.serializeUser (user, done) => done null, user
    passport.deserializeUser (user, done) => done null, user

module.exports = Router
