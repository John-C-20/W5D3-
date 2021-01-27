require "sqlite3"
require "singleton"

class QuestionsDatabase < SQLite3::Database
    include Singleton

    def initialize
        super("questions.db")
        self.type_translation = true
        self.result_as_hash = true
    end
end

class User

end

class Question

end

class QuestionFollow

end

class Reply

end

class QuestionLike

end