class AddUserIdToDatabaseSources < ActiveRecord::Migration[6.0]
  def change
    add_column :database_sources, :user_id, :integer
    add_index :database_sources, :user_id
  end
end
