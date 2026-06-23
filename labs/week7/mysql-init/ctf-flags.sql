USE exampledb;

CREATE TABLE IF NOT EXISTS ctf_flags (
    id INT AUTO_INCREMENT PRIMARY KEY,
    level VARCHAR(10) NOT NULL,
    flag VARCHAR(100) NOT NULL
);

INSERT INTO ctf_flags (level, flag) VALUES
('user', 'flag{w7_sql_enumeration_success}');
