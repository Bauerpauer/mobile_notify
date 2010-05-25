module APNs4r
  
  SANDBOX_GATEWAY_URI = URI.parse("apns://gateway.sandbox.push.apple.com:2195")
  PRODUCTION_GATEWAY_URI = URI.parse("apns://gateway.push.apple.com:2195")

  class Connection
    
    class ConnectionTimeoutError < StandardError
      def initialize(uri, timeout, original_error)
        super("Unable to establish connection to #{uri.host}:#{uri.port} within #{timeout} seconds.  SSL Reported: #{original_error.inspect}")
      end
    end

    class TransmissionTimeoutError < StandardError
      def initialize(uri, timeout, original_error)
        super("Unable to send data to #{uri.host}:#{uri.port} within #{timeout} seconds.  SSL Reported: #{original_error.inspect}")
      end
    end
    
    CONNECTION_TIMEOUT = 30
    CONNECTION_RETRY_DELAY = 2
    
    TRANSMISSION_TIMEOUT = 10 
    TRANSMISSION_RETRY_DELAY = 2
    
    def initialize(uri, certificate_file, key_file)
      @uri = uri
      @certificate_file = certificate_file
      @key_file = key_file

      @ssl_context = OpenSSL::SSL::SSLContext.new()
      @ssl_context.cert = OpenSSL::X509::Certificate.new(File::read(certificate_file))
      @ssl_context.key  = OpenSSL::PKey::RSA.new(File::read(key_file))
      @tcp_socket = TCPSocket.new(@uri.host, @uri.port)
    end

    def send(notification)
      execute do |socket|
        socket.write(notification.to_data)
      end
    end
    
    def close
      true
    end

    protected
    
    def establish_connection
      unless defined?(retry_timer)
        retry_timer = 0 
      end

      ssl_socket = OpenSSL::SSL::SSLSocket.new(@tcp_socket, @ssl_context)
      ssl_socket.connect
      # close underlying socket on SSLSocket#close
      ssl_socket.sync_close = true

      ssl_socket
    rescue OpenSSL::SSL::SSLError, Errno::EPIPE
      puts "ESTABLISH_CONNECTION: #{$!}"

      sleep(CONNECTION_RETRY_DELAY)
      retry_timer += CONNECTION_RETRY_DELAY
      retry if retry_timer < CONNECTION_TIMEOUT

      raise ConnectionTimeoutError.new(@uri, CONNECTION_TIMEOUT, $!) if retry_timer >= CONNECTION_TIMEOUT
    end

    def execute
      unless defined?(retry_timer)
        retry_timer = 0
      end

      ssl_socket = establish_connection

      yield ssl_socket

      ssl_socket.close
      ssl_socket = nil
    rescue OpenSSL::SSL::SSLError, Errno::EPIPE
      puts "EXECUTE: #{$!}"

      sleep(TRANSMISSION_RETRY_DELAY)
      retry_timer += TRANSMISSION_RETRY_DELAY
      retry if retry_timer < TRANSMISSION_TIMEOUT

      raise TransmissionTimeoutError.new(@uri, TRANSMISSION_TIMEOUT, $!) if retry_timer >= TRANSMISSION_TIMEOUT
    end

  end

end

