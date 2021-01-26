require 'sendgrid-ruby'
include SendGrid
require 'json'

class MessageHandler
  attr_accessor :title, :subject, :recipients, :content, :ss_id, :sheet_id, :oauth_token, :sheet_name

  def initialize(options={})
    @title = options[:title]
    @subject = options[:subject]
    @recipients = options[:recipients] || []
    @content = options[:content]
    @ss_id = options[:ss_id]
    @sheet_id = options[:sheet_id]
    @oauth_token = options[:oauth_token]
    @sheet_name = options[:sheet_name]
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
    mail.add_attachment(generate_attachment)

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    sg.client.mail._('send').post(request_body: mail.to_json)
  end

  def generate_attachment
    body = download_sheet_file
    attachment = SendGrid::Attachment.new
    attachment.content = Base64.strict_encode64(body)
    attachment.type = 'application/vnd.openxmlformatsofficedocument.spreadsheetml.sheet'
    attachment.filename = "#{@sheet_name}.xlsx"
    attachment.disposition = 'attachment'
    attachment.content_id = 'Report sheet'
    attachment
  end

  def download_sheet_file
    download_url = "https://docs.google.com/spreadsheets/d/#{@ss_id}/export?exportFormat=xlsx&gid=#{@sheet_id}"
    resp = HTTParty.get(download_url, headers: { 'authorization' => "Bearer #{@oauth_token}" })
    resp.body
  end
end
