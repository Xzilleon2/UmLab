require_relative "./Schedules.Class.rb"

class SchedulesView < Schedules

  def initialize
    super()
  end

  # Method to to return schedules for the current month
  def get_schedules()
    
    # Get the schedule from DB
    check_schedules()

  end

end