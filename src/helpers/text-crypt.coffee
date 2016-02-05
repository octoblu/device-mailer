crypto = require('crypto')
cryptkey = crypto.createHash('sha256').update(process.env.AES_KEY or 'localmailer').digest()
iv = new Buffer(process.env.AES_IV or 'NOTANONCEPETER!!')
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
