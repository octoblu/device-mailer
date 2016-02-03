# mailer-service
Service for sending email using arbitrary mailers

# SES example:
meshblu-util message -d '{
  "devices":["some-mailer-service-device"],
  "transporter":"ses",
  "transportOptions": {
    "accessKeyId":"SOMEACCESSKEYID",
    "secretAccessKey":"SOMESECRETACCESSKEY",
    "region":"us-west-2"
  },
  "message": {
    "from":"c@octoblu.com",
    "to":"a@octoblu.com",
    "subject":"you\'re fired!",
    "text":"http://www.howilabs.com/stuff/att-fax.jpg"
  }
}'
