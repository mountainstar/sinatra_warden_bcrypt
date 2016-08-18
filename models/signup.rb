


require 'dm-validations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")

class User

  include DataMapper::Resource



  property :id, Serial
  property :username, String,:unique => true, :required => true
  property :email, String, :required => true, :unique => true, format: :email_address
  property :password, BCryptHash, :required => true, :unique => true
  property :admin, Boolean, :default  => false
  timestamps :at

  include BCrypt

  attr_accessor :password_confirmation
  validates_confirmation_of :password, :confirm => :password_confirmation
  validates_length_of :password_confirmation, :min => 6




  def authenticate(attempted_password)
    # The BCrypt class, which `self.password` is an instance of, has `==` defined to compare a
    # test plain text string to the encrypted string and converts `attempted_password` to a BCrypt
    # for the comparison.
    #
    # But don't take my word for it, check out the source: https://github.com/codahale/bcrypt-ruby/blob/master/lib/bcrypt/password.rb#L64-L67
    if self.password == attempted_password
      true
    else
      #false
    end
  end

  def reset_password(password, confirmation)
    update(:password => password, :password_confirmation => confirmation)
  end


end

def authorized?
 if session[:id].nil?
   false
 else
   true
 end
end

# Tell DataMapper the models are done being defined
DataMapper.finalize

# Update the database to match the properties of User.
DataMapper.auto_upgrade!