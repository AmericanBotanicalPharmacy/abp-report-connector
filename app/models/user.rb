class User < ApplicationRecord
  has_many :sources, class_name: 'DatabaseSource'
  has_many :spreadsheets
  has_many :spreadsheet_jobs, through: :spreadsheets

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, omniauth_providers: [:google_oauth2]


  def self.from_omniauth(access_token)
    data = access_token.info
    sub = access_token.extra.id_info.sub
    user = User.find_or_initialize_by(sub: sub)

    attrs_to_update = {
      email: data['email'],
      name: data['name'],
      google_token: access_token.credentials.token
    }
    refresh_token = access_token.credentials.refresh_token
    attrs_to_update[:google_refresh_token] = refresh_token if refresh_token.present?

    user.update(attrs_to_update)
    user
  end

  def self.find_by_id_token(id_token='')
    raw_string = id_token.split('.')[1]
    return if raw_string.blank?
    payload = JSON.parse(Base64.decode64(raw_string))
    User.find_by(sub: payload['sub'])
  end
end
