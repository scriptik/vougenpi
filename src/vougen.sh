#!/bin/bash
###################################################################
#Script Name	: vougen.sh
#Description	: main script of vougenpi package
#Author       	: Pezhman Shafigh
#Email         	: pezhmanshafigh@gmail.com
#date           : December 2020
#license        : MIT
###################################################################
#thanks to
#https://blog.sleeplessbeastie.eu/2019/11/11/how-to-parse-ini-configuration-file-using-bash/

cat /opt/vougen/inbox/new.txt >> /home/pi/vougen/vouout.txt 
issuer=$(cat /opt/vougen/inbox/new.txt | cut -d"," -f1) #issuer
receiver=$(cat /opt/vougen/inbox/new.txt | cut -d"," -f2) #reciver
pt=$(cat /opt/vougen/inbox/new.txt | cut -d"," -f3) #profile
pryn=$(cat /opt/vougen/inbox/new.txt | cut -d"," -f4) #print yes or no
#cat /dev/null > /opt/vougen/inbox/new.txt 

# Get INI section
ReadINISections(){
  local filename="/opt/vougen/vougen.conf"
  gawk '{ if ($1 ~ /^\[/) section=tolower(gensub(/\[(.+)\]/,"\\1",1,$1)); configuration[section]=1 } END {for (key in configuration) { print key} }' ${filename}
}

# Get/Set all INI sections
GetINISections(){
  local filename="/opt/vougen/vougen.conf"

  sections="$(ReadINISections $filename)"
  for section in $sections; do
    array_name="configuration_${section}"
    declare -g -A ${array_name}
  done
  eval $(gawk -F= '{ 
                    if ($1 ~ /^\[/) 
                      section=tolower(gensub(/\[(.+)\]/,"\\1",1,$1)) 
                    else if ($1 !~ /^$/ && $1 !~ /^;/) {
                      gsub(/^[ \t]+|[ \t]+$/, "", $1); 
                      gsub(/[\[\]]/, "", $1);
                      gsub(/^[ \t]+|[ \t]+$/, "", $2); 
                      if (configuration[section][$1] == "")  
                        configuration[section][$1]=$2
                      else
                        configuration[section][$1]=configuration[section][$1]" "$2} 
                    } 
                    END {
                      for (section in configuration)    
                        for (key in configuration[section]) { 
                          section_name = section
                          gsub( "-", "_", section_name)
                          print "configuration_" section_name "[\""key"\"]=\""configuration[section][key]"\";"                        
                        }
                    }' ${filename}
        )


}

if [ -f $filename ]; then
  GetINISections "$filename"

  #echo -n "Configuration description: "
  #if [ -n "${configuration_main["description"]}" ]; then
  #  echo "${configuration_main["description"]}"
  #else
  #  echo "missing"
  #fi
  #echo

  #for section in $(ReadINISections "${filename}"); do
  #  echo "[${section}]"
  #  for key in $(eval echo $\{'!'configuration_${section}[@]\}); do
  #          echo -e "  ${key} = $(eval echo $\{configuration_${section}[$key]\})\
  #      	    (access it using $(echo $\{configuration_${section}[$key]\}))"
  #  done
  #done
else
  echo "missing CONF file"
fi
echo ${configuration_voucher[username_prefix]}
echo ${configuration_voucher[password_lenght]}
echo ${configuration_voucher[hotspot_dns]}
echo ${configuration_router[IPAddress]}
echo ${configuration_router[ApiPort]}

hotspotdns=${configuration_voucher[hotspot_dns]}
hotspotname=${configuration_voucher[hotspotname]}
password=$(openssl rand -base64 48 | cut -c1-${configuration_voucher[password_lenght]})
user=${configuration_voucher[username_prefix]}${configuration_voucher[next_user]}
profile=${configuration_profile[$pt]}
vouid=${configuration_voucher[next_id]}
qrcode_path=${configuration_settings[qrcode_path]}
voucher_path=${configuration_settings[voucher_path]}
template=${configuration_settings[template]}
qr_name="$qrcode_path$vouid.png"
voucher_name="$voucher_path$vouid.png"
DB_USER=${configuration_database[username]}
DB_PASSWD=${configuration_database[password]}
DB_NAME=${configuration_database[database]}
SSH_KEY=${configuration_router[ssh_key]}
ROUTER_IP=${configuration_router[ip]}
ROUTER_PORT=${configuration_router[port]}
ROUTER_USER=${configuration_router[user]}

echo $qr_name
qrencode -s 4 -o $qr_name "'http://$hotspotdns/login?username=$user&password=$password"

chown -R pi:pi $qrcode_path
oldu=${configuration_voucher[next_user]}
newu=$((${configuration_voucher[next_user]}+1))
oldi=${configuration_voucher[next_id]}
newi=$((${configuration_voucher[next_id]}+1))

echo $password
echo $user
echo $profile
config_file=/opt/vougen/vougen.conf
ex $config_file <<-EOF
   /^\[voucher\]
   /^next_user =
   s/$oldu/$newu/
   /^next_id =
   s/$oldi/$newi/
   wq
EOF

#echo $template
#python3 /opt/vougen/readarg.py  $qr_name $password "\"$profile\"" $template
python3 /opt/vougen/addusepass.py  $user $password "\"$profile\"" $template $voucher_name $qr_name

if [ $pryn == 1 ]; then
	pryn="Yes"
        python3 /opt/vougen/gpioled.py&
        python3 /opt/vougen/escposprint.py  $voucher_name
   else
	pryn="No"
fi
echo $pryn

mysql --user=$DB_USER --password=$DB_PASSWD $DB_NAME << EOF
INSERT INTO vouchers (issuer, receiver, username, password, profile, print, voucher_id)\
	VALUES ("$issuer", "$receiver", "$user", "$password", "$profile", "$pryn", "$vouid");
EOF

CMD="/ip hotspot user add limit-uptime=$pt name=$user password=$password server=$hotspotname"
#echo $CMD
ssh -i $SSH_KEY -p $ROUTER_PORT -o StrictHostKeyChecking=no $ROUTER_USER@$ROUTER_IP "$CMD"
