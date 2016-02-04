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

[![Build Status](https://travis-ci.org/octoblu/mailer-service.svg?branch=master)](https://travis-ci.org/octoblu/mailer-service)
[![Code Climate](https://codeclimate.com/github/octoblu/mailer-service/badges/gpa.svg)](https://codeclimate.com/github/octoblu/mailer-service)
[![Test Coverage](https://codeclimate.com/github/octoblu/mailer-service/badges/coverage.svg)](https://codeclimate.com/github/octoblu/mailer-service)
[![npm version](https://badge.fury.io/js/mailer-service.svg)](http://badge.fury.io/js/mailer-service)
[![Gitter](https://badges.gitter.im/octoblu/help.svg)](https://gitter.im/octoblu/help)
