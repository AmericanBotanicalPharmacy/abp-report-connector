class SpreadsheetsController < ApplicationController
  before_action :authenticate_user!

  def index
    @spreadsheets = current_user.spreadsheets
  end
end