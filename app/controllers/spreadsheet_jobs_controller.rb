class SpreadsheetJobsController < ApplicationController
  before_action :authenticate_user!

  def index
    @spreadsheet_jobs = current_user.spreadsheet_jobs
  end
end