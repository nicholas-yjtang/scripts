CREATE DATABASE bWAPP;
CREATE user 'bwapp'@'localhost' IDENTIFIED BY 'bug';
CREATE user 'bwapp'@'127.0.0.1' IDENTIFIED BY 'bug';
use bWAPP;
GRANT ALL PRIVILEGES ON bWAPP TO 'bwapp'@'localhost';
GRANT ALL PRIVILEGES ON bWAPP TO 'bwapp'@'127.0.0.1';