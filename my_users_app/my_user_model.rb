require 'sqlite3'

class User
  DB_FILE = 'db.sql'

  def initialize
    @db = SQLite3::Database.new(DB_FILE)
    create_table
  end

  def create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstname TEXT,
        lastname TEXT,
        age INTEGER,
        password TEXT,
        email TEXT
      )
    SQL
    @db.execute(sql)
  end

  def create(user_info)
    sql = <<-SQL
      INSERT INTO users (firstname, lastname, age, password, email)
      VALUES (?, ?, ?, ?, ?)
    SQL
    @db.execute(sql, user_info[:firstname], user_info[:lastname], user_info[:age], user_info[:password], user_info[:email])
    @db.last_insert_row_id
  end

  def find(user_id)
    @db.get_first_row("SELECT * FROM users WHERE id = ?", user_id)
  end

  def all
    @db.execute("SELECT id, firstname, lastname, age, email FROM users").map do |row|
      { id: row[0], firstname: row[1], lastname: row[2], age: row[3], email: row[4] }
    end
  end

  def update(user_id, attribute, value)
    sql = "UPDATE users SET #{attribute} = ? WHERE id = ?"
    @db.execute(sql, value, user_id)
    find(user_id)
  end

  def destroy(user_id)
    @db.execute("DELETE FROM users WHERE id = ?", user_id)
  end
end
