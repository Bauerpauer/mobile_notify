module APNs4r

  class Notification
    
    MAX_PAYLOAD_LENGTH = 256

    # Counterpart of {Notification#to_s} - parses from binary string
    # @param [String] bitstring string to parse
    # @return [Notification] parsed Notification object
    def self.parse(bitstring)
      command, tokenlen, device_token, payloadlen, payload = bitstring.unpack("CnH64na*")
      new(device_token, payload)
    end

    # Creates new notification with given token and payload
    # @param [String, Fixnum] token APNs token of device to notify
    # @param [Hash, String] payload attached payload
    # @example
    # APNs4r::Notification.new 'e754dXXXX...', { :aps => {:alert => "Hey, dude!", :badge => 1}, :custom_data => "asd" }
    def initialize(device_token, payload)
      @device_token = device_token.delete(' ')
      @payload = payload.kind_of?(Hash) ? payload.to_payload : payload
    end

    def valid?
      @payload.length <= MAX_PAYLOAD_LENGTH
    end

    # Converts to binary string wich can be writen directly into socket
    # @return [String] binary string representation
    def to_data
      [0, 32, @device_token, @payload.length, @payload ].pack("CnH*na*")
    end

  end
  
  class SimpleNotification < Notification
    
    EMPTY_BADGE = 0

    def initialize(device_token, badge_value = EMPTY_BADGE, alert = nil, sound = nil, extra = nil)
      payload = { "aps" => {} }
      payload["aps"]["badge"] = badge_value.to_i
      payload["aps"]["alert"] = alert if alert
      payload["aps"]["sound"] = sound if sound
      payload.update(extra) if extra.is_a?(Hash)

      super(device_token, payload)
    end

  end

end