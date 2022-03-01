class SpreadsheetsController < ApplicationController
  before_action :authenticate_user!

  def index
    @spreadsheets = current_user.spreadsheets
  end

  def new
    @spreadsheet = Spreadsheet.new
  end

  def create
    @spreadsheet = current_user.spreadsheets.new(spreadsheet_params)
    if @spreadsheet.save
      flash[:notice] = 'Successfully create spreadsheet'
      redirect_to spreadsheets_path
    else
      flash[:error] = @spreadsheet.errors.full_messages.join(',')
      render :new
    end
  end

  private

  def spreadsheet_params
    params.require(:spreadsheet).permit(:name, :g_id)
  end
end