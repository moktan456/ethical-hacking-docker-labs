-- Vanta Health vanta_db — seeded at first container start.
-- vhealth_app (from MARIADB_USER/MARIADB_PASSWORD) can read vanta_db.

USE vanta_db;

-- Vault key register. The stored value is an UNSALTED MD5 of the passphrase
-- that protects the encrypted patient export on the app server.
CREATE TABLE IF NOT EXISTS vault (
  id          INT PRIMARY KEY AUTO_INCREMENT,
  label       VARCHAR(128),
  secret_hash CHAR(32)
);

INSERT INTO vault (label, secret_hash) VALUES
  ('patient_export.enc passphrase (MD5)', MD5('princess'));

-- A little noise so the table isn't a one-liner.
CREATE TABLE IF NOT EXISTS clinics (
  id     INT PRIMARY KEY AUTO_INCREMENT,
  name   VARCHAR(128),
  region VARCHAR(8)
);

INSERT INTO clinics (name, region) VALUES
  ('Parkville', 'VIC'),
  ('Southbank', 'VIC'),
  ('Geelong',   'VIC');

GRANT SELECT ON vanta_db.* TO 'vhealth_app'@'%';
FLUSH PRIVILEGES;
