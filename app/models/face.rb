class Face < ActiveRecord::Base
  mount_uploader :model_file, ModelUploader
  # these fields cannot be nil
  validates :name, presence: true, length: {minimum: 4, maximum: 40}
end