class SpreadsheetDownloader
  def initialize(spreadsheet_id, sheet_id, token)
    @spreadsheet_id = spreadsheet_id
    @sheet_id = sheet_id
    @token = token
  end

  def download_as(file_path)
    url = "https://docs.google.com/spreadsheets/d/#{@spreadsheet_id}/export?exportFormat=xlsx&gid=#{@sheet_id}"
    response = HTTParty.get(url, headers: { 'authorization' => "Bearer #{@token}" })
    if response.code == 200
      File.open(file_path, "wb") do |file|
        f.write response.body      
      end
    end
  end
end
