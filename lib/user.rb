require "pg"

class User
  attr_reader :name, :email, :password, :username
  
  def initialize(id:, name:, email:, password:, username:)
    @id = id
    @name = name
    @email = email
    @password = password
    @username = username
  end

  def self.create(name:, email:, password:, username:)
    unique_error = "Username and email must be unique."
    unique_record = unique(email: email, username: username)
    p "unique: #{unique_record}"
    return unique_error if unique_record == false

    if ENV['RACK_ENV'] == "test"
      connection = PG.connect(dbname: "chitter_test")
    else
      connection = PG.connect(dbname: "chitter")
    end

    result = connection.exec(
      "INSERT INTO users (name, email, password, username)
      VALUES ('#{name}', '#{email}', '#{password}', '#{username}')
      RETURNING id, name, email, password, username;")
    User.new(
      id: result[0]["id"],
      name: result[0]["name"],
      email: result[0]["email"],
      password: result[0]["password"],
      username: result[0]["username"]
    )
  end

  def self.all
    if ENV['RACK_ENV'] == "test"
      connection = PG.connect(dbname: "chitter_test")
    else
      connection = PG.connect(dbname: "chitter")
    end

    result = connection.exec("SELECT * FROM users")
    result.map do |user|
      User.new(
        id: user["id"],
        name: user["name"],
        email: user["email"],
        password: user["password"],
        username: user["username"]
      )
    end
  end

  def self.unique(email:, username:)
    check = true

    if ENV['RACK_ENV'] == "test"
      connection = PG.connect(dbname: "chitter_test")
    else
      connection = PG.connect(dbname: "chitter")
    end
    
    result = connection.exec("SELECT * FROM users")
    list = result.map do |user|
      User.new(
      id: result[0]["id"],
      name: result[0]["name"],
      email: result[0]["email"],
      password: result[0]["password"],
      username: result[0]["username"]
      )
    end
    
    return check if list.empty?
    
    list.each do |user|
      if user.email == email
        return check = false
      elsif user.username == username
        return check = false
      end
    end
  end
end