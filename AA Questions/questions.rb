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
            WHERE fname LIKE ? AND lname LIKE ? 
        SQL
        data.map {|datum| User.new(datum)}
    end

    def self.all
        data = QuestionsDatabase.instance.execute('SELECT * FROM users')
        data.map {|datum| User.new(datum)}
    end
end

class Question
    def self.find_by_id(id)
        data = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM questions
            WHERE id = ?  
        SQL

        Question.new(data[0])
    end 
    
    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @author_id = options['author_id']
    end

    attr_accessor :id, :title, :body, :author_id

    def create
        raise "#{self} already in databse" if self.id 
        QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id)
            INSERT INTO
                questions(title, body, author_id)
            VALUES
             (?, ?, ?)
        SQL

        self.id = QuestionsDatabase.instance.last_insert_row_id
    end

    def update
        raise "#{self} not in database" unless @id 
        QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id, @id)
            UPDATE 
                questions
            SET
                title = ?, body = ?, author_id = ?
            WHERE
                id = ? 
        SQL
    end

    def self.find_by_title(title)
        data = QuestionsDatabase.instance.execute(<<-SQL, title)
            SELECT *
            FROM questions
            WHERE title LIKE ? 
        SQL
        data.map {|datum| Question.new(datum)}
    end

    def self.all
        data = QuestionsDatabase.instance.execute('SELECT * FROM questions')
        data.map {|datum| Question.new(datum)}
    end
end

class QuestionFollow
    def self.find_by_id(id)
        data = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM question_follows
            WHERE id = ?  
        SQL

        QuestionFollow.new(data[0])
    end 
    
    def initialize(options)
        @id = options['id']
        @user_id = options['user_id']
        @question_id = options['question_id']
    end

    attr_accessor :id, :user_id, :question_id

    def create
        raise "#{self} already in databse" if self.id 
        QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id)
            INSERT INTO
                question_follows(user_id, question_id)
            VALUES
             (?, ?)
        SQL

        self.id = QuestionsDatabase.instance.last_insert_row_id
    end

    def update
        raise "#{self} not in database" unless @id 
        QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id, @id)
            UPDATE 
                question_follows
            SET
                user_id = ?, question_id = ?
            WHERE
                id = ? 
        SQL
    end

    def self.find_by_user_id(user_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT *
            FROM question_follows
            WHERE user_id = ? 
        SQL
        data.map {|datum| QuestionFollow.new(datum)}
    end
    
    def self.find_by_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT *
            FROM question_follows
            WHERE question_id = ? 
        SQL
        data.map {|datum| QuestionFollow.new(datum)}
    end

    def self.all
        data = QuestionsDatabase.instance.execute('SELECT * FROM question_follows')
        data.map {|datum| QuestionFollow.new(datum)}
    end
end

class Reply
    def self.find_by_id(id)
        data = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM replies
            WHERE id = ?  
        SQL

        Reply.new(data[0])
    end 
    
    def initialize(options)
        @id = options['id']
        @subject_question_id = options['subject_question_id']
        @parent_reply_id = options['parent_reply_id']
        @author_id = options['author_id']
        @body = options['body']
    end

    attr_accessor :id, :subject_question_id, :parent_reply_id, :author_id, :body

    def create
        raise "#{self} already in databse" if self.id 
        QuestionsDatabase.instance.execute(<<-SQL, @subject_question_id, @parent_reply_id, @author_id, @body)
            INSERT INTO
                replies(subject_question_id, parent_reply_id, author_id, body)
            VALUES
             (?, ?, ?, ?)
        SQL

        self.id = QuestionsDatabase.instance.last_insert_row_id
    end

    def update
        raise "#{self} not in database" unless @id 
        QuestionsDatabase.instance.execute(<<-SQL, @subject_question_id, @parent_reply_id, @author_id, @body, @id)
            UPDATE 
                replies
            SET
                subject_question_id = ?, parent_reply_id = ?, author_id = ?, body = ?
            WHERE
                id = ? 
        SQL
    end

    def self.find_by_subject_question_id(subject_question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, subject_question_id)
            SELECT *
            FROM replies
            WHERE subject_question_id = ? 
        SQL
        data.map {|datum| Reply.new(datum)}
    end
    
    def self.find_by_parent_reply_id(parent_reply_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, parent_reply_id)
            SELECT *
            FROM replies
            WHERE parent_reply_id = ? 
        SQL
        data.map {|datum| Reply.new(datum)}
    end
    
    def self.find_by_author_id(author_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
            SELECT *
            FROM replies
            WHERE author_id = ? 
        SQL
        data.map {|datum| Reply.new(datum)}
    end

    def self.all
        data = QuestionsDatabase.instance.execute('SELECT * FROM replies')
        data.map {|datum| Reply.new(datum)}
    end
end

class QuestionLike

end