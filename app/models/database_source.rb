class DatabaseSource < ApplicationRecord
  attr_accessor :password

  before_validation :set_encrypted_password

  validates_presence_of :host, :username, :database, :port, :uuid

  def set_encrypted_password
    self.encrypted_password = Rails::Secrets.encrypt(password)
  end
end
