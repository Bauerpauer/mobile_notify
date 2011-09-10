module MobileNotify

  module Apns

    class Notification

      MAX_PAYLOAD_LENGTH = 256

      # Creates new notification with given token and payload
      def initialize(device_token, payload)
        @device_token = device_token.delete(' ')
        @payload = payload.kind_of?(Hash) ? payload.to_json : payload
      end

      def valid?
        @payload.length <= MAX_PAYLOAD_LENGTH
      end

      # Converts to binary string wich can be writen directly into socket
      # @return [String] binary string representation
      def to_s
        [0, 32, @device_token, @payload.length, @payload ].pack("CnH*na*")
      end

    end

    class AlertNotification < Notification
      def initialize(device_token, alert, sound = nil)
        payload = { "aps" => {} }
        payload["aps"]["alert"] = alert
        payload["aps"]["sound"] = sound if sound
        super(device_token, payload)
      end
    end

    class BadgeNotification < Notification
      def initialize(device_token, badge_value, sound = nil)
        payload = { "aps" => {} }
        payload["aps"]["badge"] = badge_value.to_i
        payload["aps"]["sound"] = sound if sound
        super(device_token, payload)
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

end