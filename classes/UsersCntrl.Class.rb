require_relative "./Users.Class.rb"
enable :sessions

class UsersCntrl < Users

  attr_accessor :email, :password, :code, :laboratory

  def initialize(email = "", code = "", password = "", laboratory = "")
    super()
    @email = email
    @code = code
    @password = password
    @laboratory = laboratory
  end

  # Register Method
  def register_user

    # Validate empty inputs
    if empty_inputs(@email, @code, @password, @laboratory)
      session[:message] = "Empty field input"
      return false
    end

    insert_user(@email, @code, @password, @laboratory)
  end

  # Login Method
  def login_user(email, password, session)

    # Validate empty inputs
    if empty_inputs(email, password)
      session[:message] = "Empty field input"
      return false
    end

    user = check_user(email, password)

    if user
      # Successful login: store info in session
      session[:user_id] = user['user_id']
      session[:email] = user['email']
      session[:message] = "Login successful!"
      true
    else
      # Failed login
      session[:message] = "Invalid email or password"
      false
    end

  end

  private

  # Method to check for empty inputs
  def empty_inputs(*args)
    args.each do |arg|
      return true if arg.nil? || arg.to_s.strip.empty?
    end
    false
  end

end