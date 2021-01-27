require "sqlite3"
require "singleton"
require "byebug"

class QuestionsDatabase < SQLite3::Database
    include Singleton

    def initialize
        super('questions.db')
        self.type_translation = true
        self.results_as_hash = true
    end
end

class User
    def self.find_by_id(id)
        data = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM users
            WHERE id = ?  
        SQL

        User.new(data[0])
    end 
    
    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
        @is_instructor = options['is_instructor'] 
    end

    attr_accessor :id, :fname, :lname, :is_instructor

    def create
        raise "#{self} already in databse" if self.id 
        instructor = @is_instructor ? 't' : 'f'
        QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, instructor)
            INSERT INTO
                users(fname, lname, is_instructor)
            VALUES
             (?, ?, ?)
        SQL

        self.id = QuestionsDatabase.instance.last_insert_row_id
    end

    def update
        raise "#{self} not in database" unless @id 
        instructor = @is_instructor ? 't' : 'f'
        QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, instructor, @id)
            UPDATE 
                users
            SET
                fname = ?, lname = ?, is_instructor = ?
            WHERE
                id = ? 
        SQL
    end

    def self.find_by_name(fname, lname)
        data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
            SELECT *
            FROM users
            WHERE fname = ? AND lname = ? 
        SQL
        data.map {|datum| User.new(datum)}
    end

    def self.all
        data = QuestionsDatabase.instance.execute('SELECT * FROM users')
        data.map {|datum| User.new(datum)}
    end
end

class Question

end

class QuestionFollow

end

class Reply

end

class QuestionLike

end