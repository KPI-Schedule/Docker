# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.9.19

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# set envs: HOME (required for proper composer setup), DEBIAN_FRONTEND (to disallow interactive from APT)
ENV HOME=/root \
    DEBIAN_FRONTEND=noninteractive


# add configs dir to container
ADD ./configs /docker


# enable SSH and regenerate SSH keys
RUN rm -f /etc/service/sshd/down && /etc/my_init.d/00_regen_ssh_host_keys.sh
    # uncomment following line to enable default insecure key
    #&& /usr/sbin/enable_insecure_key


RUN export TERM=xterm


# add 'ondrej/php' PPA
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php --yes && apt-get update


# install general tools
RUN apt-get install -y mc htop nano vim graphviz iputils-ping --no-install-recommends


# install php7.1
RUN apt-get update && apt-get install \
php7.1 php7.1-cli php7.1-gd php7.1-json php7.1-intl php7.1-mcrypt php7.1-curl php7.1-fpm php7.1-bcmath php7.1-xml php7.1-opcache php7.1-mbstring php7.1-zip php7.1-soap php-amqp php-redis php-ssh2 php-xdebug \
--no-install-recommends -y


# install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"\
    #&& php -r "if (hash_file('SHA384', 'composer-setup.php') === 'aa96f26c2b67226a324c27919f1eb05f21c248b987e6195cad9690d5c1ff713d53020a02ac8c217dbf90a7eacc9d141d') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"\
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer


# configure PHP-FPM
RUN mkdir /run/php \
    && cd /etc/php/7.1/fpm/pool.d \
    && { \
        echo '[global]'; \
        echo 'error_log = /proc/self/fd/2'; \
        echo 'daemonize = no'; \
        echo; \
        echo '[www]'; \
        echo 'listen = [::]:9000'; \
        echo '; if we send this to /proc/self/fd/1, it never appears'; \
        echo 'access.log = /proc/self/fd/2'; \
        echo; \
        echo 'clear_env = no'; \
        echo; \
        echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
        echo 'catch_workers_output = yes'; \
    } | tee zz-docker.conf \

    # directory for php-fpm service (look at baseimage-docker docs)

    && mkdir /etc/service/php7.1-fpm \

    # add services and configs

    && ln -s /docker/php7.1-fpm.sh /etc/service/php7.1-fpm/run \
    && ln -s /docker/php.ini /etc/php/7.1/cli/conf.d/000-docker-php.ini \
    && ln -s /docker/php.ini /etc/php/7.1/fpm/conf.d/000-docker-php.ini \
    && ln -s /docker/xdebug.ini /etc/php/7.1/fpm/conf.d/99-xdebug.ini \
    && ln -s /docker/xdebug.ini /etc/php/7.1/cli/conf.d/99-xdebug.ini


# add startup script to set proper rights on /root/.ssh/authorized_keys
RUN { \
        echo '#!/bin/bash'; \
        echo 'chown root:root /root/.ssh/authorized_keys'; \
        echo 'chmod 644 /root/.ssh/authorized_keys'; \
    } | tee /etc/my_init.d/01_ssh_fix.sh \
    && chmod +x /etc/my_init.d/01_ssh_fix.sh


# sendmail
#RUN apt-get install -y sendmail --no-install-recommends \
#    #&& line=$(head -n 1 /etc/hosts) line2=$(echo $line | awk '{print $2}') echo "$line $line2.localdomain" >> /etc/hosts \
#    && echo '127.0.0.1 localhost.localdomain localhost' >> /etc/hosts \
#    && /etc/init.d/sendmail start


# ssmtp
RUN apt-get install -y ssmtp --no-install-recommends \
    && echo "root=dockercms@gmail.com\nmailhub=smtp.gmail.com:587\nhostname=smtp.gmail.com:587\nUseSTARTTLS=YES\nAuthUser=dockercms@gmail.com\nAuthPass=zaq1xsw2cde3\nFromLineOverride=YES" > /etc/ssmtp/ssmtp.conf


# clean up APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


EXPOSE 9000
