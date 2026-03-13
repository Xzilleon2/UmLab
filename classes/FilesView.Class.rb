require_relative "./Files.Class.rb"

class FilesView < Files

  def initialize
    super()
  end

  def get_files
    view_files()
  end
end