require "pg"
require "time"

class Peep
  attr_reader :id, :message, :created_at

  def initialize(id:, message:, created_at:)
    @id = id
    @message = message
    @created_at = created_at
  end

  def self.create(message:)
    if ENV['RACK_ENV'] == "test"
      connection = PG.connect(dbname: 'chitter_test')
    else
      connection = PG.connect(dbname: 'chitter')
    end

    result = connection.exec(
      "INSERT INTO peeps (message)
      VALUES ('#{message}')
      RETURNING id, message, created_at;"
    )
    Peep.new(
      id: result[0]['id'],
      message: result[0]['message'],
      created_at: result[0]['created_at']
    )
  end

  def self.all
    if ENV['RACK_ENV'] == "test"
      connection = PG.connect(dbname: "chitter_test")
    else
      connection = PG.connect(dbname: "chitter")
    end

    result = connection.exec("SELECT * FROM peeps;")
    list = result.map do |peep|
      epoch = Time.parse(peep["created_at"]).to_i
      date = Time.at(epoch).strftime("%e %b %Y at %H:%M")
      Peep.new(
        id: peep["id"],
        message: peep["message"],
        created_at: date
      )
    end
    list.reverse
  end
end
