class ScheduledNotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @scheduled_notifications = current_user.scheduled_notifications
  end
end