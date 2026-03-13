require 'pg'

class Dbh

  def initialize
    @dbh = PG.connect(
      host: "localhost",
      user: "postgres",
      password: "0704",
      dbname: "umlab"
    )
  end

  protected

  def connect
    @dbh
  end

end