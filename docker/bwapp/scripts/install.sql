CREATE user 'bwapp'@'localhost' IDENTIFIED BY 'bug';
CREATE user 'bwapp'@'127.0.0.1' IDENTIFIED BY 'bug';
GRANT ALL PRIVILEGES ON *.* TO 'bwapp'@'localhost';
GRANT ALL PRIVILEGES ON *.* TO 'bwapp'@'127.0.0.1';