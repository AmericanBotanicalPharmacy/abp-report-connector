require 'google/api_client/client_secrets.rb'
require "google/apis/sheets_v4"
require "googleauth"

class SheetWraper
  def initialize(user)
    @user = user
    authorize
  end

  def fetch_sheet_data(spreadsheet_id, range)
    response = @service.get_spreadsheet_values spreadsheet_id, range
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

  def append_data(spreadsheet_id, range, values)
    data = [
      range: range,
      values: values
    ]
    value_range_object = Google::Apis::SheetsV4::ValueRange.new(range:  range, values: values)
    @service.append_spreadsheet_value(spreadsheet_id, range, value_range_object, value_input_option: 'RAW')
  end

  def sheet_exists?(spreadsheet_id, sheet_name)
    info = get_sheet_info(spreadsheet_id)
    !!info.sheets.find{|s| s.properties.title == sheet_name }
  end

  def clear_sheet(spreadsheet_id, sheet_name)
    @service.clear_values(spreadsheet_id, sheet_name)
  end

  def get_sheet_info(spreadsheet_id)
    @service.get_spreadsheet(spreadsheet_id)
  end

  def add_sheet(spreadsheet_id, sheet_name)
    add_sheet_request = Google::Apis::SheetsV4::AddSheetRequest.new
    add_sheet_request.properties = Google::Apis::SheetsV4::SheetProperties.new
    add_sheet_request.properties.title = sheet_name

    batch_update_spreadsheet_request = Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new
    batch_update_spreadsheet_request.requests = Google::Apis::SheetsV4::Request.new

    batch_update_spreadsheet_request_object = [ add_sheet: add_sheet_request ]
    batch_update_spreadsheet_request.requests = batch_update_spreadsheet_request_object
    response = service.batch_update_spreadsheet(spreadsheet_id, batch_update_spreadsheet_request)
  end

  def authorize
    @service = Google::Apis::SheetsV4::SheetsService.new
    @service.authorization = google_secret.to_authorization
    @service.authorization.refresh!
  end
end
