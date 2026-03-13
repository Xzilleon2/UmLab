require_relative "./Items.Class.rb"

class ItemsView < Items

  def initialize
    super()
  end

  # Method to to return schedules for the current month
  def get_items()
    
    # Get the schedule from DB
    check_inventory()

  end

end