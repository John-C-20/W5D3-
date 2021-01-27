require_relative "questions.rb"

class QuestionLike
 def self.find_by_id(id)
        data = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM question_likes
            WHERE id = ?  
        SQL

        QuestionLike.new(data[0])
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
                question_likes(user_id, question_id)
            VALUES
             (?, ?)
        SQL

        self.id = QuestionsDatabase.instance.last_insert_row_id
    end

    def update
        raise "#{self} not in database" unless @id 
        QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id, @id)
            UPDATE 
                question_likes
            SET
                user_id = ?, question_id = ?
            WHERE
                id = ? 
        SQL
    end

    def self.find_by_user_id(user_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT *
            FROM question_likes
            WHERE user_id = ? 
        SQL
        data.map {|datum| QuestionLike.new(datum)}
    end
    
    def self.find_by_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT *
            FROM question_likes
            WHERE question_id = ? 
        SQL
        data.map {|datum| QuestionLike.new(datum)}
    end

    def self.all
        data = QuestionsDatabase.instance.execute('SELECT * FROM question_likes')
        data.map {|datum| QuestionLike.new(datum)}
    end    
end