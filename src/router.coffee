url                   = require 'url'
passport              = require 'passport'
MeshbluAuth           = require 'express-meshblu-auth'
DeviceController      = require './controllers/device-controller'
CredentialsController = require './controllers/credentials-controller'
OctobluStrategy       = require 'passport-octoblu'

class Router
  constructor: ({service, @serviceUrl, @octobluOauthUrl, @meshbluConfig}, dependencies={}) ->
    throw new Error "a service is required in order to make a channeldevice" unless service?
    throw new Error "an octobluOauthUrl is required in order to make a channeldevice" unless @octobluOauthUrl?
    throw new Error "a meshbluConfig is required in order to make a channeldevice" unless @meshbluConfig?

    @deviceController      = new DeviceController {service, @serviceUrl}
    @credentialsController = new CredentialsController {service, @serviceUrl}

  route: (app) =>
    app.use passport.initialize()
    app.use passport.session()
    @setupOctobluOauth clientID: @meshbluConfig.uuid, clientSecret: @meshbluConfig.token

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
      authorizationURL: "#{@octobluOauthUrl}/authorize"
      tokenURL: "#{@octobluOauthUrl}/access_token"
      clientSecret: clientSecret
      callbackURL: "#{@serviceUrl}/octoblu/authenticate"
      passReqToCallback: true

    passport.use new OctobluStrategy octobluStrategyConfig, (req, bearerToken, secret, {uuid}, next) =>
      next null, {uuid, bearerToken}

    passport.serializeUser (user, done) => done null, user
    passport.deserializeUser (user, done) => done null, user

module.exports = Router
