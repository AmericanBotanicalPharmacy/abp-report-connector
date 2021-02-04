class User < ApplicationRecord
  has_many :sources, class_name: 'DatabaseSource'
end
