require "http"
require "json"

class Carbon::PostmarkAdapter < Carbon::Adapter
  private getter server_token : String

  def initialize(@server_token)
  end

  def deliver_now(email : Carbon::Email)
    Carbon::PostmarkAdapter::Email.new(email, server_token).deliver
  end

  class Email
    BASE_URI       = "api.postmarkapp.com"
    MAIL_SEND_PATH = "/email"
    private getter email, server_token
    
    def initialize(@email : Carbon::Email, @server_token : String)
    end

    def deliver
      client.post(MAIL_SEND_PATH, body: params.to_json).tap do |response|
        unless response.success?
          raise JSON.parse(response.body).inspect
        end
      end
    end

    # :nodoc:
    # Used only for testing
    def params
      {
        "From" => from,
        "To" => to_postmark_address(email.to),
        "Cc" => to_postmark_address(email.cc),
        "Bcc" => to_postmark_address(email.bcc),
        "Subject" => email.subject,
        "HtmlBody" => email.html_body.to_s,
        "TextBody" => email.text_body.to_s,
        "ReplyTo" => email.headers["ReplyTo"]?,
        "Tag" => email.headers["Tag"]?,
        "TrackOpens" => email.headers["TrackOpens"]?,
        "TrackLinks" => email.headers["TrackLinks"]?,
        "MessageStream" => email.headers["MessageStream"]?
      }.reject { |_key, value| value.blank? }
    end

    private def from
      "#{email.from.name} <#{email.from.address}>"
    end
    
    private def to_postmark_address(addresses : Array(Carbon::Address))
      addresses.map do |carbon_address|
        "#{carbon_address.name} <#{carbon_address.address}>"
      end.join(',')
    end

    @_client : HTTP::Client?

    private def client : HTTP::Client
      @_client ||= HTTP::Client.new(BASE_URI, port: 443, tls: true).tap do |client|
        client.before_request do |request|
          request.headers["Accept"] = "application/json"
          request.headers["Content-Type"] = "application/json"
          request.headers["X-Postmark-Server-Token"] = server_token
        end
      end
    end
  end
end
