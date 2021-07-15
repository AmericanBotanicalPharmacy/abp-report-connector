class AddCronToJobNotifications < ActiveRecord::Migration[6.0]
  def change
    add_column :job_notifications, :cron, :string
  end
end
