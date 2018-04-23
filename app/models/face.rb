class Face < ActiveRecord::Base
  mount_uploader :model_file, ModelUploader
  # these fields cannot be nil
  validates :name, presence: true, uniqueness: true, length: {minimum: 2, maximum: 40}
  validates :_type, presence: true
  validates :position, presence: true
end