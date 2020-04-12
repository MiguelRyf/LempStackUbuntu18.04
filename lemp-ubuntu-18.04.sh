#!/bin/bash

# Script author: Miguel Emmara
# Script site: https://www.miguelemmara.me
# One Click LEMP Ubuntu 18.04 Installation Script
#--------------------------------------------------
# Software version:
# 1. OS: Ubuntu 18.04.3 LTS (Bionic Beaver)
# 2. Nginx: 1.17.9 (Ubuntu)
# 3. MariaDB: 10.4.12-MariaDB
# 4. PHP: 7.4.4
#--------------------------------------------------

set -e

# Colours
red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

    # Function update os
    clear
    echo "${grn}Starting update os ...${end}"
    echo ""
    sleep 3
    apt-get update 
	DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq 
    echo ""
    sleep 1

    # Allow openSSH UFW
    echo "${grn}Allow openSSH UFW ...${end}"
    echo "" 
    sleep 2
    ufw allow OpenSSH 
    echo ""
    sleep 1

    # Enabling UFW
    echo "${grn}Enabling UFW ...${end}"
    echo ""
    sleep 2
    yes | ufw enable 
    echo "y"
    echo ""
    sleep 1

    # Install MariaDB server
    echo "${grn}Installing MariaDB ...${end}"
    echo "" 
    sleep 2
    apt-get install software-properties-common
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
    add-apt-repository "deb [arch=amd64,arm64,ppc64el] http://mariadb.mirror.liquidtelecom.com/repo/10.4/ubuntu $(lsb_release -cs) main"
    apt update
    apt -y install mariadb-server mariadb-client
    echo ""
    sleep 1

    echo "${grn}Installing PHP 7.4 ...${end}"
    echo ""
    sleep 2
    apt install software-properties-common
    add-apt-repository ppa:ondrej/php -y
    apt update
    apt install php7.4-common php7.4-mysql php7.4-xml php7.4-xmlrpc php7.4-curl php7.4-gd php7.4-imagick php7.4-cli php7.4-dev php7.4-imap php7.4-mbstring php7.4-opcache php7.4-soap php7.4-zip php7.4-intl -y
    apt-get install nginx php7.4-fpm -y
    echo ""
    sleep 1

    # Install and start nginx
    echo "${grn}Installing NGINX ...${end}"
    echo ""
    sleep 3
    echo 'deb [arch=amd64] http://nginx.org/packages/mainline/ubuntu/ bionic nginx' >> /etc/apt/sources.list.d/nginx.list
    echo 'deb-src http://nginx.org/packages/mainline/ubuntu/ bionic nginx' >> /etc/apt/sources.list.d/nginx.list
    wget http://nginx.org/keys/nginx_signing.key
    apt-key add nginx_signing.key
    apt update
    apt-get install nginx -y

        # Configure PHP FPM
    sed -i "s/max_execution_time = 30/max_execution_time = 360/g" /etc/php/7.4/fpm/php.ini
    sed -i "s/error_reporting = .*/error_reporting = E_ALL \& ~E_NOTICE \& ~E_STRICT \& ~E_DEPRECATED/" /etc/php/7.4/fpm/php.ini
    sed -i "s/display_errors = .*/display_errors = Off/" /etc/php/7.4/fpm/php.ini
    sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.4/fpm/php.ini
    sed -i "s/upload_max_filesize = .*/upload_max_filesize = 256M/" /etc/php/7.4/fpm/php.ini
    sed -i "s/post_max_size = .*/post_max_size = 256M/" /etc/php/7.4/fpm/php.ini
    echo ""
    sleep 1

    # Installing Memcached
    echo "${grn}Installing Memcached ...${end}"
    echo ""
    sleep 2
    apt install memcached -y 
    echo ""
    sleep 1
    apt install php-memcached -y 
    sleep 1

    # Installing IONCUBE
    echo "${grn}Installing IONCUBE ...${end}"
    echo ""
    sleep 2
    # PHP Modules folder
    MODULES=$(php -i | grep ^extension_dir | awk '{print $NF}')
 
    # PHP Version
    PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
 
    # Download ioncube
    wget https://www.ioncube.com/php-7.4.0-beta-loaders/ioncube_loaders_lin_x86-64_7.4_BETA2.tar.gz
    tar -xvzf ioncube_loaders_lin_x86-64_7.4_BETA2.tar.gz
    rm -f ioncube_loaders_lin_x86-64_7.4_BETA2.tar.gz 
    # Copy files to modules folder
    sudo cp "ioncube_loader_lin_${PHP_VERSION}_10.4.0_beta2.so" $MODULES 
    echo "zend_extension=$MODULES/ioncube_loader_lin_${PHP_VERSION}_10.4.0_beta2.so" >> /etc/php/7.4/fpm/php.ini
    echo "zend_extension=$MODULES/ioncube_loader_lin_${PHP_VERSION}_10.4.0_beta2.so" >> /etc/php/7.4/cli/php.ini

    rm -rf ioncube
    systemctl restart php7.4-fpm.service 
    systemctl restart nginx 

    # Mcrypt 
    apt-get -y install gcc make autoconf libc-dev pkg-config
    apt-get -y install libmcrypt-dev
    yes | pecl install mcrypt-1.0.2
    echo "extension=$MODULES/mcrypt.so" >> /etc/php/7.4/fpm/php.ini
    echo "extension=$MODULES/mcrypt.so" >> /etc/php/7.4/cli/php.ini
    systemctl restart php7.4-fpm.service 
    systemctl restart nginx 
    echo ""
    sleep 1

    # Install and start nginx
    echo "${grn}Installing HTOP ...${end}"
    echo ""
    sleep 2
    apt-get install htop 
    echo ""
    sleep 1

    # Install netstat
    echo "${grn}Installing netstat ...${end}"
    echo ""
    sleep 2
    apt install net-tools -y 
    netstat -ptuln 
    echo ""
    sleep 1

    # Install OPENSSL
    echo "${grn}Installing OPENSSL${end}"
    echo ""
    sleep 2
    cd /etc/ssl/certs/
    openssl dhparam -dsaparam -out dhparam.pem 4096 
    cd
    ufw allow 'Nginx Full' 
    ufw delete allow 'Nginx HTTP' 
    echo ""
    sleep 1

    # Install AB BENCHMARKING TOOL
    echo "${grn}Installing AB BENCHMARKING TOOL ...${end}"
    echo ""
    sleep 2
    apt-get install apache2-utils -y 
    echo ""
    sleep 1

    # Install ZIP AND UNZIP
    echo "${grn}Installing ZIP AND UNZIP ...${end}"
    echo ""
    sleep 2
    apt-get install unzip 
    apt-get install zip 
    echo ""
    sleep 1

    # Install FFMPEG and IMAGEMAGICK
    echo "${grn}Installing FFMPEG AND IMAGEMAGICK...${end}"
    echo ""
    sleep 2
    apt-get install imagemagick -y 
    apt-get install ffmpeg -y 
    echo ""
    sleep 1

    # Tuning Nginx Configurartion
    echo "${grn}Tuning Nginx Configurartion...${end}"
    echo ""
    sleep 2
    rm -rf /etc/nginx/nginx.conf 
    cd /etc/nginx/
    wget https://raw.githubusercontent.com/MiguelRyf/LempStackUbuntu18.04/master/scripts/nginx.conf?token=AOZC7LJXCFVZYYRQS4DJYPC6TPKL2 -O nginx.conf 
    dos2unix /etc/nginx/nginx.conf 
    cd
    echo ""
    sleep 1

    # Change Login Greeting
    echo "${grn}Change Login Greeting ...${end}"
    echo ""
    sleep 2
    cat > .bashrc << EOF
echo "########################### SERVER CONFIGURED BY MIGUEL EMMARA ###########################"
echo " ######################## FULL INSTRUCTIONS GO TO MIGUELEMMARA.ME ####################### "
echo ""
echo " __  __ _                  _   ______"                                    
echo "|  \/  (_)                | | |  ____|                                    "
echo "| \  / |_  __ _ _   _  ___| | | |__   _ __ ___  _ __ ___   __ _ _ __ __ _ "
echo "| |\/| | |/ _  | | | |/ _ \ | |  __| | '_   _ \| '_   _ \ / _  | '__/ _  |"
echo "| |  | | | (_| | |_| |  __/ | | |____| | | | | | | | | | | (_| | | | (_| |"
echo "|_|  |_|_|\__, |\__,_|\___|_| |______|_| |_| |_|_| |_| |_|\__,_|_|  \__,_|"
echo "           __/ |"                                                        
echo "          |___/"
echo ""
./menu.sh
EOF
echo ""
sleep 1

    # PHP POOL SETTING
    echo "${grn}Configuring to make PHP-FPM working with Nginx ...${end}"
    echo ""
    sleep 3
    php7_dotdeb="https://raw.githubusercontent.com/MiguelRyf/LempStackUbuntu18.04/master/scripts/php7dotdeb?token=AOZC7LJZGTLGFSVRYEDDPE26TPKL4"
    wget -q $php7_dotdeb -O /etc/php/7.4/fpm/pool.d/$domain.conf 
    sed -i "s/domain.com/$domain/g" /etc/php/7.4/fpm/pool.d/$domain.conf
    echo "" >> /etc/php/7.4/fpm/pool.d/$domain.conf
    dos2unix /etc/php/7.4/fpm/pool.d/$domain.conf 
    service php7.4-fpm reload 

        # Restart nginx and php-fpm
    echo "${grn}Restart Nginx & PHP-FPM ...${end}"
    echo ""
    sleep 1
    systemctl restart nginx 
    systemctl restart php7.4-fpm.service 

     # Menu Script
    cd
    wget https://raw.githubusercontent.com/MiguelRyf/LempStackUbuntu18.04/master/scripts/menu.sh?token=AOZC7LJRNKDCBCL5ATDLDJ26TPKLY -O menu.sh 
    dos2unix menu.sh 
    chmod +x menu.sh

    # Success Prompt
    #clear
    echo "LEMP Auto Installer BY Miguel Emmara `date`"
    echo "*******************************************************************************************"
    echo ""
    echo " __  __ _                  _   ______"                                    
    echo "|  \/  (_)                | | |  ____|                                    "
    echo "| \  / |_  __ _ _   _  ___| | | |__   _ __ ___  _ __ ___   __ _ _ __ __ _ "
    echo "| |\/| | |/ _  | | | |/ _ \ | |  __| | '_   _ \| '_   _ \ / _  | '__/ _  |"
    echo "| |  | | | (_| | |_| |  __/ | | |____| | | | | | | | | | | (_| | | | (_| |"
    echo "|_|  |_|_|\__, |\__,_|\___|_| |______|_| |_| |_|_| |_| |_|\__,_|_|  \__,_|"
    echo "           __/ |"                                                        
    echo "          |___/"
    echo ""
    echo "********************* OPEN MENU BY TYPING ${grn}./menu.sh${end} ******************************"
    echo ""

rm -f /root/lemp-ubuntu-18.04.sh
exit
