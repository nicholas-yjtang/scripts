#!/bin/bash
pushd /var/www/html
unzip bWAPPv2.2.zip
pushd bWAPP
chmod 777 passwords/
chmod 777 images/
chmod 777 documents/
mkdir logs
chmod 777 logs/
sed -i 's/$db_server = "localhost";/$db_server = "127.0.0.1";/g' /var/www/html/bWAPP/admin/settings.php
sed -i 's/$db_username = "root";/$db_username = "bwapp";/g' /var/www/html/bWAPP/admin/settings.php
sed -i 's/$db_password = "";/$db_password = "bug";/g' /var/www/html/bWAPP/admin/settings.php
sed -i 's/$db = 0;/$db = 0; mysqli_report(MYSQLI_REPORT_OFF);/g' /var/www/html/bWAPP/install.php
declare -a php_files=("connect.php" "functions_external.php" "hpp-2.php" "hpp-3.php" "sqli_1.php" "sqli_10-2.php" "sqli_13.php" "sqli_15.php" "sqli_16.php" "sqli_2.php" "sqli_3.php" "sqli_4.php" "sqli_5.php" "sqli_6.php" "sqli_9.php" "ws_soap.php" "xss_href-2.php" "xss_href-3.php" "xss_login.php")
for php_file in "${php_files[@]}"; do
    sed -i 's/mysql_/mysqli_/g' /var/www/html/bWAPP/$php_file
    sed -i 's/mysqli_query($sql, $link)/mysqli_query($link, $sql)/g' /var/www/html/bWAPP/$php_file
done
sed -i 's/mysqli_select_db($database, $link);/mysqli_select_db($link, $database);/g' /var/www/html/bWAPP/connect.php
if [ $? -eq 0 ]; then
    echo "bWAPP installed successfully"
else
    echo "bWAPP installation failed"
    exit 1
fi
popd
popd
mysqld -u root &
sleep 1
mysql -u root < install.sql
if [ $? -eq 0 ]; then
    echo "sql installed successfully"
else
    echo "sql installation failed"
    exit 1
fi
apachectl start
sleep 1
response=$(curl http://localhost/bWAPP/install.php?install=yes)
if [ -z "$response" ]; then
    echo "bWAPP installation failed"
    cat /var/log/apache2/error.log
    exit 1
fi
if [ $? -eq 0 ]; then
    echo "bWAPP installed successfully"
else
    echo "bWAPP installation failed"
    exit 1
fi
apachectl stop