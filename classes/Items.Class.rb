require_relative "Dbh.Class.rb"
require "pg"

class Items < Dbh

  def initialize
    super
  end

  protected
  # Method to insert items into the database
  def insert_items(name, quantity, type, picture)
    query = "
      INSERT INTO inventory (name, quantity, type, picture)
      VALUES ($1, $2, $3, $4)
    "

    begin
      connect.exec("BEGIN")
      connect.exec_params(query, [name, quantity, type, picture])
      connect.exec("COMMIT")
      true
    rescue PG::Error => e
      connect.exec("ROLLBACK")
      puts "Database error: #{e.message}"
      false
    end
  end

  # Method to update an existing schedule
  def update_inventory()

    # Query to update info
    query = "UPDATE inventory SET name=$1, quantity=$2, type=$3, picture=$4 WHERE inventory_id=$5"

    begin
      connect.exec("BEGIN")
      
      # insert updated data
      connect.exec_params(query, [
        teacher_name,        
      ])
      
      connect.exec("COMMIT")
      true
    rescue PG::Error => e
      connect.exec("ROLLBACK")
      puts "Database error: #{e.message}"
      false
    end
  end

  # Method to delete a schedule
  def delete_item()
    query = "DELETE FROM schedule WHERE schedule_id = $1"

    begin
      connect.exec("BEGIN")
      connect.exec_params(query, [schedule_id])
      connect.exec("COMMIT")
      true
    rescue PG::Error => e
      connect.exec("ROLLBACK")
      puts "Database error: #{e.message}"
      false
    end
  end

  # Method to get schedules for the current month
  def check_inventory()

    query = "
      SELECT *
      FROM inventory
      WHERE quantity > 0
      ORDER BY inventory_id
    "

    begin
      result = connect.exec(query)
      result.to_a || []
    rescue PG::Error => e
      puts "Database error: #{e.message}"
      []
    end
  end

  # insert a reservation and cart items
  def insert_reservation(name, type, date_of_use, class_code, course_title, program, cart_items = [])
    reservation_query = "
      INSERT INTO reservation (name, type, date_of_use, class_code, course_title, program) 
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING reservation_id
    "

    cart_query = "
      INSERT INTO cart (reservation_id, inventory_id, quantity)
      VALUES ($1, $2, $3)
    "

    begin
      connect.exec("BEGIN")
      
      # Insert reservation and get the reservation_id
      result = connect.exec_params(reservation_query, [name, type, date_of_use, class_code, course_title, program])
      reservation_id = result[0]['reservation_id'].to_i
      
      # Insert each cart item
      if cart_items && cart_items.length > 0
        cart_items.each do |item|
          inventory_id = item[:id]
          quantity = item[:qty]
          connect.exec_params(cart_query, [reservation_id, inventory_id, quantity])
        end
      end
      
      connect.exec("COMMIT")
      true
    rescue PG::Error => e
      connect.exec("ROLLBACK")
      puts "Database error: #{e.message}"
      false
    end
  end

  # Get all reservations with their cart items and inventory details
  def get_reservations()
    query = "
      SELECT 
        r.reservation_id,
        r.name,
        r.type,
        r.date_of_use,
        r.class_code,
        r.course_title,
        r.program,
        r.date_filled,
        i.name as material_name,
        c.quantity,
        c.cart_id,
        c.status
      FROM reservation r
      LEFT JOIN cart c ON r.reservation_id = c.reservation_id
      LEFT JOIN inventory i ON c.inventory_id = i.inventory_id
      ORDER BY r.reservation_id DESC, c.cart_id
    "

    begin
      result = connect.exec(query)
      result.to_a || []
    rescue PG::Error => e
      puts "Database error: #{e.message}"
      []
    end
  end

  # Update cart item status
  def update_cart_status(cart_id, status)
    get_cart_info = "SELECT c.status as current_status, c.inventory_id, c.quantity FROM cart c WHERE c.cart_id = $1"
    update_query = "UPDATE cart SET status = $1 WHERE cart_id = $2"
    deduct_inventory = "UPDATE inventory SET quantity = quantity - $1 WHERE inventory_id = $2"
    restore_inventory = "UPDATE inventory SET quantity = quantity + $1 WHERE inventory_id = $2"

    begin
      connect.exec("BEGIN")
      # Get current status and item details
      result = connect.exec_params(get_cart_info, [cart_id])
      if result.ntuples > 0
        current_status = result[0]['current_status']
        inventory_id = result[0]['inventory_id']
        quantity = result[0]['quantity'].to_i

        # Only deduct inventory if transitioning to 'approved' from non-approved
        if status == 'approved' && current_status != 'approved'
          connect.exec_params(deduct_inventory, [quantity, inventory_id])
        end

        # Only restore inventory if transitioning to 'returned' from 'approved'
        if status == 'returned' && current_status == 'approved'
          connect.exec_params(restore_inventory, [quantity, inventory_id])
        end
      end
      connect.exec_params(update_query, [status, cart_id])
      connect.exec("COMMIT")
      true
    rescue PG::Error => e
      connect.exec("ROLLBACK")
      puts "Database error: #{e.message}"
      false
    end
  end

  # Update all cart items for a reservation to a specific status
  def update_reservation_status(reservation_id, status)
    query = "UPDATE cart SET status = $1 WHERE reservation_id = $2"

    begin
      connect.exec("BEGIN")
      connect.exec_params(query, [status, reservation_id])
      connect.exec("COMMIT")
      true
    rescue PG::Error => e
      connect.exec("ROLLBACK")
      puts "Database error: #{e.message}"
      false
    end
  end

  # Update existing inventory item
  def update_inventory(inventory_id, name, quantity, type, picture)
    query = "UPDATE inventory SET name=$1, quantity=$2, type=$3, picture=$4 WHERE inventory_id=$5"
    begin
      connect.exec_params(query, [name, quantity, type, picture, inventory_id])
      true
    rescue PG::Error => e
      puts "Database error: #{e.message}"
      false
    end
  end

  # Delete existing inventory item
  def remove_inventory(inventory_id)
    query = "DELETE FROM inventory WHERE inventory_id=$1"
    begin
      connect.exec_params(query, [inventory_id])
      true
    rescue PG::Error => e
      puts "Database error: #{e.message}"
      false
    end
  end

end