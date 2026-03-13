require_relative "./Items.Class.rb"

class ReservedCntrl < Items

  attr_accessor :name, :type, :date_of_use, :class_code, :course_title, :program, :cart_items

  def initialize(name = "", type = "", date_of_use = "", class_code = "", course_title = "", program = "", cart_items = [])
    super()
    @name = name
    @type = type
    @date_of_use = date_of_use
    @class_code = class_code
    @course_title = course_title
    @program = program
    @cart_items = cart_items
  end

  # Add a new reservation
  def add_reservation(session)
    if empty_inputs(@name, @type, @date_of_use, @class_code, @course_title, @program)
      session[:reservation_message] = "Empty field input"
      return false
    end

    if @cart_items.nil? || @cart_items.empty?
      session[:reservation_message] = "No items in cart"
      return false
    end

    # Call parent class method to insert reservation into database
    result = insert_reservation(@name, @type, @date_of_use, @class_code, @course_title, @program, @cart_items)
    
    if result
      session[:reservation_message] = "Reservation added successfully!"
      return true
    else
      session[:reservation_message] = "Failed to add reservation"
      return false
    end
  end

  # Update Cart Status
  def update_cart_status(cart_id, status)
    super
  end

  # Update Reservation Status
  def update_reservation_status(cart_id, status)
    super
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