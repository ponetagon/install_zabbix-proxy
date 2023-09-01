######################################
######################################
#    Install zabbix proxy 6.0 LTS    #
#          Github/poentagon          #
######################################
######################################
#!/bin/bash

Install-Proxy()
{
	wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu20.04_all.deb
	dpkg -i zabbix-release_6.0-4+ubuntu20.04_all.deb
	apt update -y 
	apt install -y zabbix-proxy-mysql zabbix-sql-scripts
}
############
Install-MYSQL()
{
	sudo apt update -y
	apt-get install -y mysql-server-8.0
	systemctl restart mysql
	systemctl enable mysql
}
############
Create-database()
{
	 mysql -e "create database zabbix_proxy character set utf8mb4 collate utf8mb4_bin;"
	 mysql -e "create user 'zabbix'@'localhost' identified by '$PASSWORD';"
	 mysql -e "grant all privileges on zabbix_proxy.* to zabbix@localhost;"
	 mysql -e "set global log_bin_trust_function_creators = 1;"
	 cat /usr/share/zabbix-sql-scripts/mysql/proxy.sql | mysql --default-character-set=utf8mb4 -uzabbix -p"$PASSWORD" zabbix_proxy
}
##########
Edit-config()
{
	config_file="/etc/zabbix/zabbix_proxy.conf"
	if [ -f "$config_file" ]; then
  	    # Update Server setting
	    sudo sed -i "s/^Server=.*/Server=$IP/" "$config_file"

	    # Update DBPassword setting
	    sudo sed -i "s/^# DBPassword=.*/DBPassword=$PASSWORD/" "$config_file"

	    # Update ProxyName value
	    sudo sed -i "s/^Hostname=.*/Hostname=$NAME/" "$config_file"

	    # Update EnableRemoteCommands value to 1
	    sudo sed -i "s/^# EnableRemoteCommands=0/EnableRemoteCommands=1/" "$config_file"

            # Update ConfigFrequency value to 10
	    sudo sed -i "s/^# ConfigFrequency=3600/ConfigFrequency=10/" "$config_file"

	    echo "Updated Server,DBPassword,Hostname settings in $config_file"
	else
	    echo "Configuration file $config_file not found."
	fi
}

read -p "Enter Name Zabbix Proxy(default:Zabbix proxy): " NAME
read -p "Enter a password for mysql: " PASSWORD
read -p "Enter IP Zabbix Server: " IP


Install-Proxy
Install-MYSQL
Create-database
Edit-config
#mysql -e "set global log_bin_trust_function_creators = 0;"
systemctl restart zabbix-proxy
systemctl enable zabbix-proxy
