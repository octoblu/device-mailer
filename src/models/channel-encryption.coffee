NodeRSA = require 'node-rsa'
_       = require 'lodash'

class ChannelEncryption
  constructor: ({privateKey}) ->
    throw new Error('Private key not found!') unless privateKey?
    @key = @createNodeRSA privateKey

  createNodeRSA: (keyString) =>
    return new NodeRSA keyString  if _.startsWith keyString, '-----'

    keyBinary = new Buffer keyString, 'base64'
    return new NodeRSA keyBinary, 'pkcs1-der'

  getPrivateKeyEnvironmentValue: =>
    @key.exportKey('private-der').toString 'base64'

  getPublicKey: () =>
    @key.exportKey 'public'

  authToCode: ({uuid, token}) =>
    newAuth = "#{uuid}:#{token}"
    verifier =
      auth: newAuth
      signature: @sign newAuth

    return new Buffer(JSON.stringify(verifier)).toString('base64')

  codeToAuth: (code) =>
    {auth, signature} = JSON.parse(new Buffer(code, 'base64').toString())
    verified = @verify auth, signature
    [uuid, token] = auth.split ':'

    return {uuid, token, verified}

  encryptOptions: (options) =>
    @key.encrypt(JSON.stringify options).toString 'base64'

  decryptOptions: (options) =>
    decryptedOptions = JSON.parse @key.decrypt(options)

  sign: (options) =>
    optionsBuffer = new Buffer(options)
    @key.sign optionsBuffer

  verify: (options, signature) =>
    optionsBuffer = new Buffer options
    signatureBuffer = new Buffer signature, 'base64'

    @key.verify optionsBuffer, signatureBuffer

module.exports = ChannelEncryption
