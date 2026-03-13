require_relative "./Schedules.Class.rb"
enable :sessions

class SchedulesCntrl < Schedules

  attr_accessor :user_id, :teacher_name, :class_time, :lab_schedule, :class_code, :classroom_number, :course, :status

  def initialize(user_id = "", teacher_name = "", class_time = "", lab_schedule = "", class_code = "", classroom_number = "", course = "", status = "")
    super()
    @user_id = user_id
    @teacher_name = teacher_name
    @class_time = class_time
    @lab_schedule = lab_schedule
    @class_code = class_code
    @classroom_number = classroom_number
    @course = course
    @status = status
  end

  # Add a new schedule
  def add_schedule(session)
    if empty_inputs(@user_id, @teacher_name, @class_time, @lab_schedule, @class_code, @classroom_number, @course, @status)
      session[:schedule_message] = "Empty field input"
      return false
    end

    result = insert_schedule(@user_id, @teacher_name, @class_time, @lab_schedule, @class_code, @classroom_number, @course, @status)
    true
  end

  # Update an existing schedule
  def update_schedule_data(schedule_id, teacher_name, class_time, lab_schedule, class_code, classroom_number, course, status, session)

    # Check empty inputs
    if empty_inputs(schedule_id, teacher_name, class_time, lab_schedule, class_code, classroom_number, course, status)
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

  private

  # Method to check for empty inputs
  def empty_inputs(*args)
    args.each do |arg|
      return true if arg.nil? || arg.to_s.strip.empty?
    end
    false
  end

end