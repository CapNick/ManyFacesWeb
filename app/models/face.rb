class Face < ActiveRecord::Base
  mount_uploader :photo_file, ModelUploader
  # these fields cannot be nil
  validates :name, presence: true, length: {minimum: 4, maximum: 40}
  validates :room, presence: true, length: {minimum: 2, maximum: 50}
  validates :email, presence: true, length: {minimum: 6, maximum: 60}
end