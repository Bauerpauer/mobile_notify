Apns4r
======

This lib is intended to allow write my own APNs provider for Apple Push
Notificaion services (APNs) in ruby.  Requires json gem.

Configuration
=============

If you want to use APNs certificates with ruby (ie with OpenSSL),
here's a tip from [great post about integration between Python and APNs](http://blog.nuclearbunny.org/2009/05/11/connecting-to-apple-push-notification-services-using-python-twisted/):

>One caveat  - the Mac OS X Keychain Access application does not directly export
>certificates and private keys in Private Enhanced Mail (.pem)  format, which is
>what the OpenSSL implementation we use with Twisted will want, but luckily
>there’s an easy mechanism to convert if you export the files as Personal
>Information Exchange (.p12) format. The following two commands can be used to
>convert the .p12 files into .pem files using the built-in openssl command on
>Mac OS X or most Linux distributions:

    openssl pkcs12 -in cred.p12 -out certkey.pem -nodes -clcerts
    openssl pcks12 -in pkey.p12 -out pkey.pem -nodes -clcerts

Example
=======

    require "rubygems"
    require "apns4r"

    c = APNs4r::Connection.new(APNs4r::SANDBOX_GATEWAY_URI, "/path/to/cert.pem", "/path/to/key.pem")
    c.send(APNs4r::SimpleNotification.new("some device token", 27, "Check out the new ride!", "default"))

Doc
===

Copyright (c) 2010 Scott Bauer, released under the MIT license
