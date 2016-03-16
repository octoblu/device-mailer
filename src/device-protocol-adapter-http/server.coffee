cors               = require 'cors'
morgan             = require 'morgan'
express            = require 'express'
bodyParser         = require 'body-parser'
errorHandler       = require 'errorhandler'
cookieParser       = require 'cookie-parser'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
MeshbluConfig      = require 'meshblu-config'
Router             = require './router'

class Server
  constructor: ({@disableLogging, @port, @service, @serviceUrl}, {@meshbluConfig}={})->
    @meshbluConfig ?= new MeshbluConfig().toJSON()
    @serviceUrl ?= process.env.SERVICE_URL
    
  address: =>
    @server.address()

  run: (callback) =>
    app = express()
    app.use meshbluHealthcheck()
    app.use morgan 'dev', immediate: false unless @disableLogging
    app.use cors()
    app.use errorHandler()
    app.use cookieParser()
    app.use bodyParser.urlencoded limit: '50mb', extended : true
    app.use bodyParser.json limit : '50mb'

    app.options '*', cors()

    router = new Router {@meshbluConfig, @service, @serviceUrl}

    router.route app

    @server = app.listen @port, callback

  stop: (callback) =>
    @server.close callback

module.exports = Server
