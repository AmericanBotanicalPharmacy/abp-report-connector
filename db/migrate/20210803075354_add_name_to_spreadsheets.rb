class AddNameToSpreadsheets < ActiveRecord::Migration[6.0]
  def change
    add_column :spreadsheets, :name, :string
  end
end
