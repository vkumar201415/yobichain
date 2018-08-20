#!/bin/bash

source yobichain.conf

db_root_pass=$1
db_admin_user=$2
db_admin_pass=$3

chainname=$4
networkport=$5
rpcport=$6

echo -e \
'--------------------------------------------'"\n"\
'Parameters in the configure-yobichain'"\n"\
'--------------------------------------------'"\n"\
'chainname='$4"\n"\
'rpcport='$6"\n"\
'networkport='$5"\n\n"\





homedir=`su -l $linux_admin_user -c 'cd ~ && pwd'`
source $homedir/.multichain/$chainname/multichain.conf

user_id=1
user_password_hash=`php -r 'echo password_hash("'$default_user_pass'",PASSWORD_BCRYPT);'`

user_addr=`curl --user $rpcuser:$rpcpassword --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "getnewaddress", "params": [] }' -H 'content-type: text/json;' http://127.0.0.1:$rpcport | jq -r '.result'`

user_pubkey=`curl --user $rpcuser:$rpcpassword --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "validateaddress", "params": ["'$user_addr'"] }' -H 'content-type: text/json;' http://127.0.0.1:$rpcport | jq -r '.result.pubkey'`

su -l $linux_admin_user -c  "multichain-cli "$chainname" grant "$user_addr" send,receive,issue > /dev/null 2>/dev/null"

su -l $linux_admin_user -c  "multichain-cli "$chainname" grant "$user_addr" file_data.write > /dev/null 2>/dev/null"
su -l $linux_admin_user -c  "multichain-cli "$chainname" grant "$user_addr" file_details.write > /dev/null 2>/dev/null"
su -l $linux_admin_user -c  "multichain-cli "$chainname" grant "$user_addr" asset_details.write > /dev/null 2>/dev/null"
su -l $linux_admin_user -c  "multichain-cli "$chainname" grant "$user_addr" offers_hex.write > /dev/null 2>/dev/null"
su -l $linux_admin_user -c  "multichain-cli "$chainname" grant "$user_addr" offers_details.write > /dev/null 2>/dev/null"


echo ''
echo ''
echo -e 'SETTING UP DATABASE. Please wait...'
echo ''
echo ''
echo ''

mysql -u root -p$db_root_pass -Bse 'SET GLOBAL FOREIGN_KEY_CHECKS=0;'
mysql -u root -p$db_root_pass -Bse 'DROP DATABASE IF EXISTS `'$db_name'`'
mysql -u root -p$db_root_pass -Bse 'CREATE DATABASE IF NOT EXISTS `'$db_name'`'
mysql --user=root --password=$db_root_pass $db_name < $db_file_name

mysql -u root -p$db_root_pass -Bse "CREATE USER IF NOT EXISTS '"$db_admin_user"'@'localhost' IDENTIFIED BY '"$db_admin_pass"';GRANT ALL PRIVILEGES ON \`"$db_name"\`. * TO '"$db_admin_user"'@'localhost';FLUSH PRIVILEGES;"

mysql -u root -p$db_root_pass $db_name -Bse 'SET GLOBAL FOREIGN_KEY_CHECKS=1'

echo ''
echo ''
echo ''

echo -e '-----------------------------'
echo -e 'YOBICHAIN CONFIGURED SUCCESSFULLY!'
echo -e '-----------------------------'
echo ''
echo ''
