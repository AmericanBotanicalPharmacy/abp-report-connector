class AddNameToDatabaseSources < ActiveRecord::Migration[6.0]
  def change
    add_column :database_sources, :name, :string
  end
end
