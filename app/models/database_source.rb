class DatabaseSource < ApplicationRecord
  attr_accessor :password

  before_validation :set_encrypted_password

  validates_presence_of :host, :username, :database, :port, :uuid

  def set_encrypted_password
    if password.present?
      self.encrypted_password = Rails::Secrets.encrypt(password)
    end
  end

  def decrypted_password
    if password.blank? && encrypted_password.present?
      self.password = Rails::Secrets.decrypt(encrypted_password)
    end
  end

  def generate_database_url
    decrypted_password
    # mysql2://root@localhost/abp_report_connector_development
    # sqlserver://sa:StrongPassword!@localhost/abp_report_connector_development
    case db_type
    when 'mysql'
      "mysql2://#{username}:#{password}@#{host}:#{port}/#{database}"
    when 'sqlserver'
      "sqlserver://#{username}:#{password}@#{host}:#{port}/#{database}"
    end
  end
end
