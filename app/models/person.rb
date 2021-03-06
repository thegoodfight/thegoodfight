class Person < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Tire::Model::Search
  include Tire::Model::Callbacks
  extend FriendlyId
  extend Groupable

  module FacebookType
    PERSON = "person"
    PAGE   = "page"
    ALL    = [ PAGE, PERSON ]
    COLLECTION = ALL.map {|k| [ k.titleize, k ]}
  end

  mapping do
    indexes :id,           :index    => :not_analyzed
    indexes :slug,         :index    => :not_analyzed
    indexes :name,         :analyzer => 'snowball', :boost => 100
    indexes :title,        :analyzer => 'snowball'
    indexes :description,  :analyzer => 'snowball'
    indexes :created_at,   :type => 'date', :include_in_all => false
  end

  has_many :appearances, as: :guest
  has_many :episodes, through: :appearances
  has_many :hosted_episodes, class_name: "Episode", foreign_key: :host_id
  belongs_to :organization

  mount_uploader :image, ImageUploader

  friendly_id :name, use: :slugged

  scope :with_episodes, where("appearances_count > 0").order("name ASC")

  default_scope { order("name ASC") }
  default_value_for(:facebook_type) { Person::FacebookType::PERSON }

  def facebook_page?
    self.facebook_type == Person::FacebookType::PAGE
  end

  def groupable_by
    self.name.chars.first
  end
end
