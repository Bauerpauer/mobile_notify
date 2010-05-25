class Hash
  MAX_PAYLOAD_LEN = 256

  # Converts hash into JSON String.
  # When payload is too long but can be chopped, tries to cut self.[:aps][:alert].
  # If payload still don't fit Apple's restrictions, returns nil
  #
  # @return [String, nil] the object converted into JSON or nil.
  def to_payload
    # Payload too long
    if (to_json.length > MAX_PAYLOAD_LEN)
      alert = self[:aps][:alert]
      self[:aps][:alert] = ''
      # can be chopped?
      if (to_json.length > MAX_PAYLOAD_LEN)
        return nil
      else # inefficient way, but payload may be full of unicode-escaped chars, so...
        self[:aps][:alert] = alert
        while (self.to_json.length > MAX_PAYLOAD_LEN)
          self[:aps][:alert].chop!
        end
      end
    end
    to_json
  end

end
