class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize (name:, breed:, id:nil)
    self.name = name
    self.breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def self.create(name:,breed:)
    dog = Dog.new(name:name, breed:breed)

    dog.save
  end

  def self.find_by_id(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = #{id}").first
    Dog.new_from_db(row)
  end

  def self.new_from_db(attribute_array)
    dog = Dog.new(id:attribute_array[0],name:attribute_array[1],breed:attribute_array[2])
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}'").first
    Dog.new_from_db(row)
  end

  def self.find_or_create_by(name:,breed:)
    find_sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    dog = DB[:conn].execute(find_sql, name, breed)
    if dog.empty?
      new_dog = Dog.create(name:name, breed:breed)
      return new_dog
    else
      old_dog = Dog.new_from_db(dog[0][0])
      return old_dog
    end
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?,?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    return self
  end


end
