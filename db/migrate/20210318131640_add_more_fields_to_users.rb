class AddMoreFieldsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :name, :string
    add_column :users, :sub, :string, index: true
    add_column :users, :google_token, :string
    add_column :users, :google_refresh_token, :string
  end
end
