module APNs4r

  require 'socket'
  require 'openssl'


  class Sender
    @@ssl = nil
    @@environment = nil


    def self.establishConnection environment
      @@environment ||= environment
      return if @@ssl
      host = ( environment.to_sym == :sandbox ? 'gateway.sandbox.push.apple.com' : 'gateway.push.apple.com' )
      port = 2195
      certdir   = File.expand_path(File.dirname(__FILE__))+'/../cert'
      cert_file = File.join(certdir , 'apns_developer_identity.cer')
      key_file  = File.join(certdir , 'apns_developer_private_key.pem')

      ctx = OpenSSL::SSL::SSLContext.new()
      if cert_file && key_file
        ctx.cert = OpenSSL::X509::Certificate.new(File::read(cert_file))
        ctx.key  = OpenSSL::PKey::RSA.new(File::read(key_file))
      end

      s = TCPSocket.new(host, port)
      @@ssl = OpenSSL::SSL::SSLSocket.new(s, ctx)
      @@ssl.connect # start SSL session
      @@ssl.sync_close = true # close underlying socket on SSLSocket#close
    end

    def self.send notification
      begin
        @@ssl.write notification
      rescue OpenSSL::SSL::SSLError, Errno::EPIPE
        self.establishConnection @@environment
        @@ssl.write notification
      end
    end

    def self.closeConnection
      @@ssl.close
      @@ssl = nil
    end

  end

end

