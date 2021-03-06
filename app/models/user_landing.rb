class UserLanding < ActiveRecord::Base
  belongs_to :user
  belongs_to :landing
  belongs_to :partner_link

  validates_presence_of :user, :landing

  def init
  	self.is_club ||= false
  end

  # JUST To the ActiveJob
  def expiring?
    (Time.now + 2.days) > reactivate_at
  end
  def expired?
  	!is_club && (Time.now > reactivate_at)
  end
end
