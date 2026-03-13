require_relative "./Files.Class.rb"
enable :sessions

class FilesCntrl < Files

  attr_accessor :prof_name, :course_code, :course_title, :filename

  def initialize(prof_name = "", course_code = "", course_title = "", filename = "")
    super()
    @prof_name = prof_name
    @course_code = course_code
    @course_title = course_title
    @filename = filename
  end

  # Add a new Excel file record
  def add_file(session)
    if empty_inputs(@prof_name, @course_code, @course_title, @filename)
      session[:file_message] = "Empty field input"
      return false
    end

    result = insert_file(@prof_name, @course_code, @course_title, @filename)
    if result
      session[:file_message] = "File added successfully!"
    else
      session[:file_message] = "Failed to add file."
    end
    result
  end

  # View all uploaded files
  def get_files
    view_files
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