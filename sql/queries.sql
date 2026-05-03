CREATE TABLE students (
    id INTEGER PRIMARY KEY,
    name TEXT,
    age INTEGER
);

INSERT INTO students (name, age)
VALUES ('Alice', 19);

SELECT * FROM students;