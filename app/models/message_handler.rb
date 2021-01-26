require 'sendgrid-ruby'
include SendGrid
require 'json'

class MessageHandler
  attr_accessor :title, :subject, :recipients, :content

  def initialize(options={})
    @title = options[:title]
    @subject = options[:subject]
    @recipients = options[:recipients] || []
    @content = options[:content]
  end

  def deliver
    mail = SendGrid::Mail.new
    mail.from = Email.new(email: ENV['MAIL_FROM'])
    mail.subject = @subject
    personalization = Personalization.new
    @recipients.each do |recipient|
      personalization.add_to(Email.new(email: recipient))
    end
    mail.add_personalization(personalization)
    mail.add_content(Content.new(type: 'text/plain', value: content))

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    sg.client.mail._('send').post(request_body: mail.to_json)
  end
end
