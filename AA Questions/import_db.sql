PRAGMA foreign_keys = ON; 

CREATE TABLE users(
    id INTEGER PRIMARY KEY,
    fname TEXT,
    lname TEXT
);


CREATE TABLE questions(
    id INTEGER PRIMARY KEY,
    title TEXT ,
    body TEXT ,
    author_id INTEGER NOT NULL, 

    FOREIGN KEY(author_id) REFERENCES users(id)
 );

CREATE TABLE question_follows(
    --join table has its own id and foreign key corresponds 
    --to user id that it joins to question_id, will have 2 foreign keys 
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(question_id) REFERENCES questions(id)
);

CREATE TABLE replies(
    id INTEGER PRIMARY KEY,
    subject_question_id INTEGER NOT NULL,
    parent_reply_id INTEGER,
    author_id INTEGER, 
    body TEXT, 

    FOREIGN KEY(subject_question_id) REFERENCES questions(id),
    FOREIGN KEY(parent_reply_id) REFERENCES replies(id),
    FOREIGN KEY(author_id) REFERENCES users(id)
);

CREATE TABLE question_likes(
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    question_id INTEGER, 

    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(question_id) REFERENCES questions(id)   
);

INSERT INTO
users(fname, lname)
VALUES
('Brad', 'Trick'),
('John', 'Cheung');

INSERT INTO
questions(title, body, author_id)
VALUES
('Help', 'Why doesn''t this work?', 1);

INSERT INTO
question_follows(user_id, question_id)
VALUES
(1,1),
(2,1);

INSERT INTO
replies(subject_question_id, parent_reply_id, user_id, body)
VALUES
(1, NULL, 2, 'IDK either');

INSERT INTO
question_likes(user_id, question_id)
VALUES
(1,1),
(2,1);



