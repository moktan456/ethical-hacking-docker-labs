-- Meridian Freight company_db — seeded at first container start.
-- webuser (created from MARIADB_USER/MARIADB_PASSWORD) can read company_db.

USE company_db;

-- Finance vault key register. The stored value is an UNSALTED MD5 of the
-- passphrase that protects the encrypted Q4 export on the app server.
CREATE TABLE IF NOT EXISTS vault (
  id          INT PRIMARY KEY AUTO_INCREMENT,
  label       VARCHAR(128),
  secret_hash CHAR(32)
);

INSERT INTO vault (label, secret_hash) VALUES
  ('q4_export.enc passphrase (MD5)', MD5('sunshine'));

-- A little noise so the table isn't a one-liner.
CREATE TABLE IF NOT EXISTS clients (
  id     INT PRIMARY KEY AUTO_INCREMENT,
  name   VARCHAR(128),
  region VARCHAR(8)
);

INSERT INTO clients (name, region) VALUES
  ('Harbourline Imports', 'NSW'),
  ('Redgum Haulage',      'VIC'),
  ('Coral Sea Shipping',  'QLD');

GRANT SELECT ON company_db.* TO 'webuser'@'%';
FLUSH PRIVILEGES;
