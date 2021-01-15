class CreateDatabaseSources < ActiveRecord::Migration[6.0]
  def change
    create_table :database_sources do |t|
      t.string :db_type
      t.string :host
      t.string :database
      t.string :uuid
      t.string :username
      t.string :encrypted_password
      t.string :port

      t.timestamps
    end
  end
end
