require_relative "questions.rb"

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

    def self.find_by_question_id(subject_question_id)
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
    
    def self.find_by_user_id(author_id)
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

    def author
        raise "#{self} has no listed author" unless author_id 
        User.find_by_id(author_id) 
    end

    def question
        Question.find_by_id(subject_question_id) 
    end

    def parent_reply
        Reply.find_by_id(parent_reply_id)
    end

    def child_replies
        Reply.find_by_parent_reply_id(id)
    end
end