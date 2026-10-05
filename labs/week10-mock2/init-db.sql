-- CyberGuard Corp Database
-- Week 10 Mock Exam 2 - Database initialization

USE company_db;

CREATE TABLE IF NOT EXISTS projects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    client_name VARCHAR(100),
    status VARCHAR(20),
    budget DECIMAL(10,2),
    start_date DATE
);

INSERT INTO projects (project_name, client_name, status, budget, start_date) VALUES
('Network Security Audit', 'TechCorp Inc', 'active', 50000.00, '2026-09-01'),
('Web Application Pentest', 'Finance Solutions Ltd', 'completed', 35000.00, '2026-08-15');

-- Flag 3 vault. Nothing here is a plaintext flag: md5_hash must be cracked
-- offline (john/hashcat + rockyou), and its plaintext is the openssl
-- decryption key for enc_blob_b64 (aes-256-cbc, pbkdf2, base64-encoded).
-- Reached only with the webuser credentials leaked on ssh-target.
CREATE TABLE IF NOT EXISTS vault (
    id INT AUTO_INCREMENT PRIMARY KEY,
    label VARCHAR(50) NOT NULL,
    md5_hash VARCHAR(32) NOT NULL,
    enc_blob_b64 TEXT NOT NULL,
    note VARCHAR(255)
);

INSERT INTO vault (label, md5_hash, enc_blob_b64, note) VALUES
('flag3',
 '84d961568a65073a3bcf0eb216b2a576',
 'U2FsdGVkX1+kWIiCLSTepSNxIymg1/mChBvMGseyhA32aJ9xUzqHdWKCpU4dwj2aX1At2OrGwD5dmlI4SeZ8zw==',
 'crack md5_hash, then: base64 -d | openssl enc -aes-256-cbc -pbkdf2 -d -k <cracked password>');

GRANT SELECT ON company_db.projects TO 'webuser'@'%';
GRANT SELECT ON company_db.vault TO 'webuser'@'%';
FLUSH PRIVILEGES;
