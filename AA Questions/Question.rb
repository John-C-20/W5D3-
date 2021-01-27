# require_relative "questions.rb"
require_relative "setup.rb"

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

    def self.find_by_author_id(author_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
            SELECT *
            FROM questions
            WHERE author_id = ? 
        SQL
        data.map {|datum| Question.new(datum)}
    end

    def author
        raise "#{self} has no listed author" unless author_id 
        User.find_by_id(author_id) 
    end

    def replies
        raise "#{self} is not listed in the database" unless id 
        Reply.find_by_question_id(id) 
    end
    
    def followers
        QuestionFollow.followers_for_question_id(@id)
    end
end