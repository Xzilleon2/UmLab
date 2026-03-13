require_relative "./Items.Class.rb"
enable :sessions

class ItemsCntrl < Items

  attr_accessor :user_id, :name, :quantity, :type, :picture

  def initialize(name = "", quantity = 0, type = "", picture = "")
    super()
    @name = name
    @quantity = quantity
    @type = type
    @picture = picture
  end

  # Add a new item
  def add_item(session)
    if empty_inputs(@name, @quantity, @type, @picture)
      session[:schedule_message] = "Empty field input"
      return false
    end

    result = insert_items(@name, @quantity, @type, @picture)
    true
  end

  # Update an existing schedule
  def update_items(name, quantity, type, picture, session)

    # Check empty inputs
    if empty_inputs(name, quantity, type, picture)
      session[:schedule_message] = "Nothing to update"
      return false
    end
    
    # Update schedule information
    result = update_schedule(schedule_id, teacher_name, class_time, lab_schedule, class_code, classroom_number, course, status)

    result
  end

  # Delete a schedule
  def remove_schedule(schedule_id, session)
    if empty_inputs(schedule_id)
      session[:schedule_message] = "Invalid schedule ID"
      return false
    end

    result = delete_schedule(schedule_id)
    result
  end

  # Attendance update method
  def update_attendance(schedule_id, status, total_hours, session)
    if empty_inputs(schedule_id, status, total_hours)
      session[:dashboard_message] = "Invalid input for attendance update"
      return false

      update_attendancedb(schedule_id, status, total_hours)
      true
    end

    update_attendancedb(schedule_id, status, total_hours)
    true
  end

  # Update an existing inventory item
  def update_item(inventory_id, name, quantity, type, picture, session)
    if name.empty? || quantity.to_i <= 0 || type.empty?
      session[:inventory_message] = "Invalid input"
      return false
    end

    # Use the provided picture (or keep existing if unchanged)
    picture_to_save = picture

    update_inventory(inventory_id, name, quantity, type, picture_to_save)
  end

  # Delete inventory item
  def delete_item(inventory_id, session)
    if inventory_id.nil? || inventory_id <= 0
      session[:inventory_message] = "Invalid inventory ID"
      return false
    end
    remove_inventory(inventory_id)
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