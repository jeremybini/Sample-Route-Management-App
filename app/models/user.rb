class User < ActiveRecord::Base
	has_secure_password

	validates_uniqueness_of :email, :on => :create, :message => 'This account already exists'
	before_create { generate_token(:auth_token) }

	def send_password_reset
		generate_token(:password_reset_token)
		self.password_reset_sent_at = Time.zone.now
		save!
		UserMailer.password_reset(self).deliver
	end

	def generate_token(column)
		begin
			self[column] = SecureRandom.urlsafe_base64
		end while User.exists?(column => self[column])
	end

	def routesetter?
		self.role === 'routesetter' || self.role === 'admin'
	end

	def admin?
		self.role === 'admin'
	end
end
