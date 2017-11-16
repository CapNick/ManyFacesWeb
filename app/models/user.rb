class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable and :omniauthable
  devise :database_authenticatable, :recoverable, :trackable, :validatable, :rememberable, :timeoutable
end
