USE corpdb;

CREATE TABLE IF NOT EXISTS ctf_flags (
    id INT AUTO_INCREMENT PRIMARY KEY,
    level VARCHAR(10) NOT NULL,
    flag VARCHAR(100) NOT NULL,
    hint VARCHAR(200) NOT NULL
);

INSERT INTO ctf_flags (level, flag, hint) VALUES
('root', 'flag{w5_mysql_data_exfil}', 'Well done — you enumerated the database and extracted the hidden flag table.');
