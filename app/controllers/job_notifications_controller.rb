class JobNotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @job_notifications = current_user.job_notifications
  end
end