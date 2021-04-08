class SqlExecutor
  def initialize(database_url, sql)
    @database_url = database_url
    @sql = sql
  end

  def execute
    conn = DbConnectionFactory.create(@database_url)
    result = conn.exec_query(@sql)
    if conn.is_a?(ActiveRecord::ConnectionAdapters::SQLServerAdapter)
      if result.count > 0
        columns = result[0].keys
        result = result.map { |r| columns.map { |c| r[c]} }
        {
          result: result,
          columns: columns
        }
      else
        {
          result: [],
          columns: []
        }
      end
    else
      {
        result: result.rows,
        columns: result.columns
      }
    end
  end
end
