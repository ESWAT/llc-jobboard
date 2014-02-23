class JobPost < ActiveRecord::Base
  belongs_to :category
  belongs_to :job_type
  belongs_to :user

  has_many :job_applications

  acts_as_taggable

  has_one :location
  accepts_nested_attributes_for :location

  scope :by_category, lambda { |category_id| where("category_id = ?", category_id) }
  scope :by_job_type, lambda { |job_type_id| where("job_type_id = ?", job_type_id) }
  scope :active, lambda { where("state = 'active'") }
  scope :expired, lambda { where("expires_at < ?", Time.now) }

  state_machine :initial => :not_approved do
    before_transition [:not_approved, :rejected, :expired] => :active, :do => :set_expiry_date

    event :activate do
      transition [:not_approved, :rejected, :expired] => :active
    end

    event :reject do
      transition all => :rejected
    end

    event :expire do
      transition all => :expired
    end

    event :hide do
      transition :active => :hidden 
    end

    event :show do
      transition :hidden => :active 
    end
  end

  def charge(token, email)
    begin
      charge = Stripe::Charge.create(
        :amount => 3000,
        :currency => "cad",
        :card => token,
        :description => "#{email} paid for #{title}"
      )
      activate
    rescue Stripe::CardError => e
      
    end
  end

  def self.hide_expired
    JobPost.expired.each { |post| post.expire }
  end

  private
  def set_expiry_date
    update(expires_at: Time.now + 30.days)
  end
end
