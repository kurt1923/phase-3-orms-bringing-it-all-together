require 'pry'

class Dog
    attr_accessor :name, :breed, :id
    
    def initialize(name:, breed:, id: nil)
        @id = id
        @name = name
        @breed = breed 
    end

  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
    SQL
    DB[:conn].execute(sql)
  end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
      end

      def save
        if self.id
          self.update
        else
          sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
          SQL
          DB[:conn].execute(sql, self.name, self.breed)
          self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
      end
# create a new row in the database to return the dog class 
    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
    end
    # This is an interesting method. Ultimately, the database is going to return an array representing a dog's data. We need a way to cast that data into the appropriate attributes of a dog. This method encapsulates that functionality. You can even think of it as new_from_array. Methods like this, that return instances of the class, are known as constructors, just like .new, except that they extend the functionality of .new without overwriting initialize.
    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end
    # this method should return an array of Dog instances for every record in the dogs table.
    def self.all
        sql = <<-SQL
        SELECT *
        FROM dogs
        SQL

        DB[:conn].execute(sql).map do |row|
            self.new_from_db(row)
        end
    end
    # The spec for this method will first insert a dog into the database and then attempt to find it by calling the find_by_name method. The expectations are that an instance of the dog class that has all the properties of a dog is returned, not primitive data.

    # Internally, what will the .find_by_name method do to find a dog; which SQL statement must it run? Additionally, what method might .find_by_name use internally to quickly take a row and create an instance to represent that data?
    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE dogs.name = ?
        LIMIT 1
        SQL

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end
    def self.find(id)
        sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE dogs.id = ?
          LIMIT 1;
        SQL
    
        DB[:conn].execute(sql, id).map do |row|
          self.new_from_db(row)
        end.first
      end
    # This method takes a name and a breed as keyword arguments. If there is already a dog in the database with the name and breed provided, it returns that dog. Otherwise, it inserts a new dog into the database, and returns the newly created dog.
    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE dog.name = ?
        AND dog.breed = ?
        LIMIT 1
        SQL

        row = DB[:conn].execute(sql, name, breed).first

        if row
            self.new_from_db(rown)
        else
            self.create(name: name, breed: breed)
        end
    end
    def update
        sql = <<-SQL
          UPDATE dogs 
          SET 
            name = ?, 
            breed = ?  
          WHERE id = ?;
        SQL
        
        DB[:conn].execute(sql, self.name, self.breed, self.id)
      end
end

