module MobileNotify
  
  module Apns
  
    SANDBOX_GATEWAY_URI = URI.parse("apns://gateway.sandbox.push.apple.com:2195")
    PRODUCTION_GATEWAY_URI = URI.parse("apns://gateway.push.apple.com:2195")

    class Connection
      
      class NotConnectedError < StandardError
        def initialize(uri)
          super("A connection to #{uri} has not yet been established.")
        end
      end

      class AlreadyConnectedError < StandardError
        def initialize(uri)
          super("A connection to #{uri} has already been established.")
        end
      end

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
    
      DEFAULT_CONNECTION_TIMEOUT = 30
      DEFAULT_CONNECTION_RETRY_DELAY = 2
      DEFAULT_TRANSMISSION_TIMEOUT = 10 
      DEFAULT_TRANSMISSION_RETRY_DELAY = 2

      attr_accessor :connection_timeout, :connection_retry_delay
      attr_accessor :transmission_timeout, :transmission_retry_delay
      
      def self.open(uri, certificate_file, key_file = certificate_file)
        connection = new(uri, certificate_file, key_file = certificate_file)
        connection.open
        yield connection
      ensure
        connection.close if connection
      end

      def initialize(uri, certificate_file, key_file = certificate_file)
        @uri = uri
        @certificate_file = certificate_file
        @key_file = key_file.nil? ? certificate_file : key_file

        @connection_timeout = DEFAULT_CONNECTION_TIMEOUT
        @connection_retry_delay = DEFAULT_CONNECTION_RETRY_DELAY
        @transmission_timeout = DEFAULT_TRANSMISSION_TIMEOUT
        @transmission_retry_delay = DEFAULT_TRANSMISSION_RETRY_DELAY

        @ssl_context = OpenSSL::SSL::SSLContext.new()
        @ssl_context.cert = OpenSSL::X509::Certificate.new(File::read(@certificate_file))
        @ssl_context.key  = OpenSSL::PKey::RSA.new(File::read(@key_file))
        @tcp_socket = TCPSocket.new(@uri.host, @uri.port)
        @ssl_socket = nil
      end
      
      def open
        raise AlreadyConnectedError.new(@uri) if @ssl_socket
        
        @ssl_socket = establish_connection
        self
      end
      
      def send(notification)
        raise NotConnectedError.new(@uri) unless @ssl_socket
        retry_timer ||= 0

        @ssl_socket.write(notification.to_data)
        self
      rescue OpenSSL::SSL::SSLError, Errno::EPIPE
        sleep(self.transmission_retry_delay)
        retry_timer += self.transmission_retry_delay
        retry if retry_timer < self.transmission_timeout

        raise TransmissionTimeoutError.new(@uri, self.transmission_timeout, $!) if retry_timer >= self.transmission_timeout
      end
    
      def close
        @ssl_socket.close if @ssl_socket
        @ssl_socket = nil

        self
      end

      protected
    
      def establish_connection
        retry_timer ||= 0

        # Wrap the TCP socket w/ SSL
        ssl_socket = OpenSSL::SSL::SSLSocket.new(@tcp_socket, @ssl_context)
        ssl_socket.connect
        ssl_socket.sync_close = true

        ssl_socket
      rescue OpenSSL::SSL::SSLError, Errno::EPIPE
        sleep(self.connection_retry_delay)
        retry_timer += self.connection_retry_delay
        retry if retry_timer < self.connection_timeout

        raise ConnectionTimeoutError.new(@uri, self.connection_timeout, $!) if retry_timer >= self.connection_timeout
      end

    end
  
  end

end

