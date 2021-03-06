class Work < ApplicationRecord
  include Careable

  belongs_to :user
  belongs_to :category

  has_many :donates
  has_many :work_messages, :dependent => :destroy

  validates :user_id, presence: true
  attr_accessor :remote_attach_avatar_url

  mount_uploader :attach_avatar, AvatarUploader

  extend FriendlyId
  friendly_id :subject, use: :slugged

  scope :order_by_new, -> { order('created_at desc') }
  scope :order_by_favorite, -> { order('cares_count desc,hits desc') }
  scope :is_published, -> { where(is_published: true)}
  scope :is_featured, -> { where(is_featured: true)}


  def should_generate_new_friendly_id?
    slug.blank? || subject_changed?
  end

  def normalize_friendly_id(input)
    input.to_s.to_slug.normalize.to_s
  end

  def subject
    read_attribute(:subject).presence
  end

end
