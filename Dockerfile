FROM debian:stretch

RUN apt-get update && apt-get upgrade -y && apt-get install -y openssh-server openssl mysql-client apt-transport-https lsb-release ca-certificates wget git

RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg

RUN sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

RUN apt-get update && apt-get install -y php7.2-common php7.2-readline php7.2-cli php7.2-gd php7.2-mysql php7.2-curl php7.2-mbstring php7.2-opcache php7.2-json php7.2-dom php7.2-intl php7.2-xsl php7.2-zip php7.2-soap php7.2-bcmath

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
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