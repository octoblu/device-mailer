_ = require 'lodash'
MeshbluHttp = require 'meshblu-http'

class CredentialsDevice
  constructor: ({@meshbluConfig}, dependencies={}) ->
    @meshbluHttp = new MeshbluHttp @meshbluConfig

  updateClientSecret: (clientSecret, callback) =>

  subscribeToUserDevice: (uuid) =>
    
module.exports = CredentialsDevice
