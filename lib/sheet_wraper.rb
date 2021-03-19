require 'google/api_client/client_secrets.rb'
require "google/apis/sheets_v4"
require "googleauth"

class SheetWraper
  def initialize(user)
    @user = user
  end

  def fetch_sheet_data(spreadsheet_id, range)
    service = Google::Apis::SheetsV4::SheetsService.new
    service.authorization = google_secret.to_authorization
    service.authorization.refresh!
    response = service.get_spreadsheet_values spreadsheet_id, range
    puts "Name, Major:"
    puts "No data found." if response.values.empty?
    response.values.each do |row|
      # Print columns A and E, which correspond to indices 0 and 4.
      puts "#{row[0]}, #{row[4]}"
    end
  end

  def google_secret
    Google::APIClient::ClientSecrets.new(
      { "web" =>
        { "access_token" => @user.google_token,
          "refresh_token" => @user.google_refresh_token,
          "client_id" => ENV['GOOGLE_CLIENT_ID'],
          "client_secret" => ENV['GOOGLE_CLIENT_SECRET'],
        }
      }
    )
  end
end
