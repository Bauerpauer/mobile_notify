mobile_notify
======

A simple library intended to provide a simple interface for sending APNS messages for iPhone, iPod, and iPad
applications.

Configuration
=============

To use this library, you'll need to export your Apple Push Services certificate and private key to a .p12 file.  Open up
Keychain Access and find the proper certificate + private key combination.  For development certs, the name of the cert
you're looking for will be in the format: "Apple Development Push Services: IDENTIFIER:APPID", for production certs, the
name is "Apple Production Push Services: IDENTIFIER:APPID".  For some reason these certs were stored under my "System"
keychain, and were missing the private key association.  Dragging the cert to the "login" keychain caused the proper
private key to associate w/ the cert.  After you're sure everything is setup, right-click the cert and export it to a
.p12 file.  Open a terminal window and run the following command:

    openssl pkcs12 -in exported_cert_and_key.p12 -out cert_and_key.pem -nodes

Example
=======

    require "rubygems"
    require "mobile_notify"

    connection = MobileNotify::Apns::Connection.new(MobileNotify::Apns::SANDBOX_GATEWAY_URI, "/path/to/cert_and_key.pem")
    connection.send(MobileNotify::Apns::SimpleNotification.new("some device token", 27, "Check out the new ride!", "default"))
    connection.close

Thanks
=======

The "meat" (i.e., the SSL stuff) of this was gleaned from several sources, namely https://github.com/thegeekbird/Apns4r.

Copyright (c) 2010 Scott Bauer, released under the MIT license