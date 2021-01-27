# require_relative "questions.rb"
# require_relative "User.rb"

require_relative "setup.rb"

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

    def self.followers_for_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT 
                users.fname, users.lname 
            FROM 
                question_follows 
             JOIN 
                 users
             ON
                 question_follows.user_id = users.id    
             JOIN
                 questions 
             ON
                 question_follows.question_id = questions.id
            WHERE questions.id = ?
        SQL
            
        data.map {|datum| User.find_by_name(datum['fname'],datum['lname'])}
    end

    def self.followed_questions_for_user_id(user_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT 
                questions.id 
            FROM 
                question_follows 
             JOIN 
                 users
             ON
                 question_follows.user_id = users.id    
             JOIN
                 questions 
             ON
                 question_follows.question_id = questions.id
            WHERE users.id = ?
        SQL
            
        data.map {|datum| Question.find_by_id(datum['id'])}
    end

    def self.most_followed_questions(n)
        data = QuestionsDatabase.instance.execute(<<-SQL, n)
            SELECT 
                question_id, COUNT(*) AS num_followers 
            FROM 
                question_follows 
            --JOIN
            --     questions 
            -- ON
            --     question_follows.question_id = questions.id
            GROUP BY question_id
            ORDER BY num_followers DESC LIMIT ?  
        SQL
            
        data.map {|datum| Question.find_by_id(datum[0])}
    end    


    # COUNT(question_id) # number of users following that question





end
