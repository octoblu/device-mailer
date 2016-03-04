_                     = require 'lodash'
debug                 = require('debug')('meshblu:device:service')

Device                = require './device'
CredentialsDeviceData = require '../../data/credentials-device-data'
CredentialsDevice     = require './credentials-device'

class ServiceDevice extends Device

  createCredentialsDevice: ({clientID}, callback) =>
    debug 'createCredentialsDevice', {clientID}
    options = _.extend {clientID, owner: @uuid}, CredentialsDeviceData
    @meshbluHttp.register options, (error, {uuid, token}={}) =>
      return callback error if error?
      callback error, new CredentialsDevice {uuid, token}

  findOrCreateCredentialsDevice: ({clientID}, callback) =>
    debug 'findOrCreateCredentialsDevice', {clientID}
    @meshbluHttp.devices {clientID: clientID, owner: @uuid}, (error, result) =>
      return callback error if error? && error?.message != 'Devices not found'
      return @createCredentialsDevice {clientID}, callback if _.isEmpty result

      {uuid} = _.first result
      @meshbluHttp.generateAndStoreToken uuid, (error, {token}={}) =>
        debug 'generated token for existing credentials device'
        return callback error if error?
        return callback null, new CredentialsDevice {uuid, token}

module.exports = ServiceDevice
