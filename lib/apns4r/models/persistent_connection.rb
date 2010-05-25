module APNs4r
  
  class PersistentConnection < Connection
    
    def close
      @ssl_socket.close if @ssl_socket

      true
    end

    protected

    def execute
      retry_timer = 0 unless defined?(retry_timer)

      @ssl_socket ||= establish_connection

      yield @ssl_socket
    rescue OpenSSL::SSL::SSLError, Errno::EPIPE
      # Reconnect Here?
      @ssl_socket.close if @ssl_socket
      @ssl_socket = establish_connection

      # Retry the execution
      sleep(TRANSMISSION_RETRY_DELAY)
      retry_timer += TRANSMISSION_RETRY_DELAY
      retry if retry_timer < TRANSMISSION_TIMEOUT

      raise TransmissionTimeoutError.new(@uri, TRANSMISSION_TIMEOUT, $!) if retry_timer >= TRANSMISSION_TIMEOUT
    end
    
  end
  
end