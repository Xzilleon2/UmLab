require_relative "Dbh.Class.rb"
require "pg"

class Files < Dbh

  def initialize
    super
  end

  protected

  # Method to insert a file record into the database
  def insert_file(prof_name, course_code, course_title, filename)
    query = "
      INSERT INTO files (prof_name, course_code, course_title, filename)
      VALUES ($1, $2, $3, $4)
    "

    begin
      connect.exec("BEGIN")
      connect.exec_params(query, [prof_name, course_code, course_title, filename])
      connect.exec("COMMIT")
      true
    rescue PG::Error => e
      connect.exec("ROLLBACK")
      puts "Database error: #{e.message}"
      false
    end
  end

  # Method to fetch all uploaded files
  def view_files()
    query = "
      SELECT *
      FROM files
      ORDER BY files_id DESC
    "

    begin
      result = connect.exec(query)
      result.to_a || []
    rescue PG::Error => e
      puts "Database error: #{e.message}"
      []
    end
  end

end