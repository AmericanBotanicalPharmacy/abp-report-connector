class DbConnectionFactory
  class DbConnection < ActiveRecord::Base; self.abstract_class= true; end

  def self.create(database_url)
    conn = DbConnection.establish_connection(database_url)
    conn.connection
  end
end
