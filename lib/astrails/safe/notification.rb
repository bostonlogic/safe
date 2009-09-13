module Astrails
  module Safe
    class Notification

      attr_accessor :config, :error
      def initialize(config, error)
        @config, @error = config, error
      end
      
      def send_failure
        if valid?
          msg = "Subject: #{subject}\n\n"
          msg += "#{subject} at #{Time.now.strftime('%A, %B %d, %Y %I:%M:%S %p')}\n\n"
          msg += "Exception: #{error.to_s}\n\n"
          msg += "Stack Trace: #{error.backtrace.join("\n")}\n"
          Net::SMTP.start(host, port, domain, username, password, authentication) do |smtp|
            smtp.send_message(msg, from, recipients)
          end
        end
      end
      
      private
      
      def valid?
        subject && host && domain && username && password && authentication && port && from && recipients
      end
       
      def subject
        @config[:notification, :subject]
      end
      
      def host
        @config[:notification, :host]
      end
      
      def domain
        @config[:notification, :domain]
      end

      def username
        @config[:notification, :username]
      end
      
      def password
        @config[:notification, :password]
      end
      
      def authentication
        @config[:notification, :authentication]
      end
      
      def port
        @config[:notification, :port]
      end
      
      def from
        @config[:notification, :from]
      end

      def recipients
        @config[:notification, :recipients]
      end
      
    end
  end
end
