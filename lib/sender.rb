module APNs4r

  class Sender < ApnsConnection

    attr_accessor :host, :port

    # Creates new {Sender} object with given host and port
    # @param [String] host default to APNs sandbox
    # @param [Fixnum] port don't think it can change, just in case
    def initialize host = OPTIONS[:apns4r_push_host], port = OPTIONS[:apns4r_push_port]
      @host, @port = host, port
      @ssl ||= connect(@host, @port)
      self
    end

    # sends {Notification} object to Apple's server
    # @param [Notification] notification notification to send
    # @example
    # n = APNs4r::Notification.create 'e754dXXXX...', { :aps => {:alert => "Hey, dude!", :badge => 1}, :custom_data => "asd" }
    # sender = APNs4r::Sender.new.push n
    def push notification
      begin
        @ssl.write notification.to_s
      rescue OpenSSL::SSL::SSLError, Errno::EPIPE
        @ssl ||= connect(@host, @port)
        retry
      end
    end

    def close_connection
      @ssl.close
      @ssl = nil
    end

  end

end

