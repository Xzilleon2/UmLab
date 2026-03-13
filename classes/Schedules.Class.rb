require_relative "Dbh.Class.rb"
require "pg"

class Schedules < Dbh

  def initialize
    super
  end

  protected
  # Method to insert schedule into the database
  def insert_schedule(user_id, teacher_name, class_time, lab_schedule, class_code, classroom_number, course, status)
    query = "
      INSERT INTO schedule 
      (user_id, teacher_name, class_time, lab_schedule, class_code, classroom_number, course, status)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    "

    begin
      connect.exec("BEGIN")
      connect.exec_params(query, [user_id, teacher_name, class_time, lab_schedule, class_code, classroom_number, course, status])
      connect.exec("COMMIT")
      true
    rescue PG::Error => e
      connect.exec("ROLLBACK")
      puts "Database error: #{e.message}"
      false
    end
  end

  # Method to update an existing schedule
  def update_schedule(schedule_id, teacher_name, class_time, lab_schedule, class_code, classroom_number, course, status)

    # Query to update info
    query = "UPDATE schedule SET teacher_name = $1, class_time = $2, lab_schedule = $3, class_code = $4, classroom_number = $5, course = $6, status = $7 WHERE schedule_id = $8"

    begin
      connect.exec("BEGIN")
      
      # insert updated data
      connect.exec_params(query, [
        teacher_name,      
        class_time,        
        lab_schedule,      
        class_code,        
        classroom_number,  
        course,            
        status,            
        schedule_id        
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
  def delete_schedule(schedule_id)
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
  def check_schedules()

    query = "
      SELECT *
      FROM schedule
      WHERE date_created >= DATE_TRUNC('month', CURRENT_DATE)
      AND date_created < DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
    "

    begin
      result = connect.exec_params(query)

      result.to_a   # convert PG::Result → array of hashes

    rescue PG::Error => e
      puts "Database error: #{e.message}"
      []
    end
  end

  # Check attendance for everyday
    def update_attendancedb(schedule_id, status, total_hours)
      query = "
        INSERT INTO attendance (schedule_id, status, total_hours) 
        VALUES ($1, $2, $3)
      "

      begin
        connect.exec("BEGIN")
        connect.exec_params(query, [schedule_id, status, total_hours])
        connect.exec("COMMIT")
        return true
        
      rescue PG::Error => e
        connect.exec("ROLLBACK")
        puts "Database error: #{e.message}"
        return false
      end
    end

end