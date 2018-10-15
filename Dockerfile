FROM debian:stretch

RUN apt-get update && apt-get upgrade -y && apt-get install -y openssh-server openssl mysql-client apt-transport-https lsb-release ca-certificates wget git

RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg

RUN sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

RUN apt-get update && apt-get install -y php7.1-common  php7.1-readline php7.1-cli php7.1-gd php7.1-mysql php7.1-mcrypt php7.1-curl php7.1-mbstring php7.1-opcache php7.1-json php7.1-dom php7.1-intl php7.1-xsl php7.1-zip php7.1-soap php7.1-bcmath

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

RUN chsh -s /bin/bash www-data && usermod -m -d /home/www-data www-data && mkdir /var/run/sshd \
        && sed -i '11 a PermitRootLogin no' /etc/ssh/sshd_config \
        && sed -i 's|#AuthorizedKeysFile\s.ssh/authorized_keys\s.ssh/authorized_keys2|AuthorizedKeysFile .ssh/authorized_keys /etc/ssh/authorized_keys/%u|' /etc/ssh/sshd_config \
        && sed -i 's|#PasswordAuthentication\syes|PasswordAuthentication no|' /etc/ssh/sshd_config

WORKDIR /var/www

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]