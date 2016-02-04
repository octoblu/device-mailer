crypto = require('crypto')
cryptkey = crypto.createHash('sha256').update(process.env.TEXT_CRYPT_KEY or 'notsecure').digest()
iv = new Buffer(process.env.TEXT_CRYPT_NONCE or 'thisisanoncense1')
AESCrypt = {}

AESCrypt.decrypt = (encryptdata) ->
  decypher = crypto.createDecipheriv('aes-256-cbc', cryptkey, iv)
  decyphered = decypher.update(encryptdata, 'hex', 'utf8')
  decyphered += decypher.final('utf8')
  decyphered

AESCrypt.encrypt = (cleardata) ->
  encypher = crypto.createCipheriv('aes-256-cbc', cryptkey, iv)
  encyphered = encypher.update(cleardata, 'utf8', 'hex')
  encyphered += encypher.final('hex')
  encyphered

module.exports = AESCrypt
