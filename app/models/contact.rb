class Contact
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :topic,      :string
  attribute :company,    :string
  attribute :industry,   :string
  attribute :name,       :string
  attribute :department, :string
  attribute :email,      :string
  attribute :phone,      :string
  attribute :budget,     :string
  attribute :start_date, :string
  attribute :engagement, :string
  attribute :detail,     :string
  attribute :consent,    :boolean

  validates :topic,   presence: true
  validates :company, presence: true
  validates :name,    presence: true
  validates :email,   presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :detail,  presence: true
  validates :consent, acceptance: true
end
