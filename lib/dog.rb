class Dog
    attr_accessor :id, :name, :breed

    def initialize (attributehash)
        attributehash.each {|key, value| self.send(("#{key}="), value)}
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          grade TEXT
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
          update
        else
          sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?,?)
          SQL
    
          DB[:conn].execute(sql, self.name, self.breed)
          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
      end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(attributehash)
        dog = self.new(attributehash)
        dog.save
        dog
     end

     def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        SQL
 
        dog = DB[:conn].execute(sql, name)[0]
        self.new_from_db(dog)
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        SQL
 
        dog = DB[:conn].execute(sql, id)[0]
        self.new_from_db(dog)
    end

    def self.new_from_db(row)
        new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
        new_dog
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
          dog_data = dog[0]
          dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
          dog = self.create(name: name, breed: breed)
        end
        dog
      end




    




end