require_relative "Items.Class.rb"
require "pg"

class ReservationsView < Items

  def show_reservations()
  
    # Get all reservations
    get_reservations()

  end

end
