require_relative "Dbh.Class.rb"
require "pg"
require "bcrypt"

class Users < Dbh

  def initialize
    super
  end

  protected
  # Method to insert a new user into the database
  def insert_user(email, code, password, laboratory)
    query = "INSERT INTO users (email, code, password, laboratory) VALUES ($1, $2, $3, $4)"
    hashed_password = BCrypt::Password.create(password)

    begin
      # Start transaction
      connect.exec("BEGIN")

      # Execute query
      connect.exec_params(query, [email, code, hashed_password, laboratory])

      # Commit transaction
      connect.exec("COMMIT")

      true

    rescue PG::Error => e
      # Rollback if there is an error
      connect.exec("ROLLBACK")
      puts "Database error: #{e.message}"
      false
    end

  end

  # Method to login user
  def check_user(email, password)
    query = "SELECT * FROM users WHERE email = $1"

    begin

      # Execute query
      result = connect.exec_params(query, [email])

      if result.ntuples == 0
        # No user found
        return false
      end

      # Get the stored hashed password
      stored_hashed_password = result[0]["password"]

      # Check input password against hashed password
      if BCrypt::Password.new(stored_hashed_password) == password
        return result[0] # Return user data if login is successful
      else
        false
      end

    rescue PG::Error => e
      # display message if there is an error
      puts "Database error: #{e.message}"
      false
    end

  end

end