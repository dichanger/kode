FROM daocloud.io/ubuntu:trusty

RUN apt-get update \
    && apt-get -y install \
        curl \
        wget \
        apache2 \
        libapache2-mod-php5 \
        php5-mysql \
        php5-sqlite \
        php5-gd \
        php5-curl \
        php-pear \
        php-apc \
    && apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && curl -sS https://getcomposer.org/installer \
        | php -- --install-dir=/usr/local/bin --filename=composer

# Apache 2 配置文件：/etc/apache2/apache2.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    # PHP 配置文件：/etc/php5/apache2/php.ini
    # 调整 PHP 处理 Request 里变量提交值的顺序，解析顺序从左到右，后解析新值覆盖旧值
    # 默认设定为 EGPCS（ENV/GET/POST/COOKIE/SERVER）
    && sed -i 's/variables_order.*/variables_order = "EGPCS"/g' \
        /etc/php5/apache2/php.ini

#设置安装目录权限
RUN chmod 777 /var/www/html
# 配置apache rewrite 重定向模块
RUN a2enmod rewrite
#RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load
#替换 AllowOverride None文件为 All
RUN sed -i 's/AllowOverride None/AllowOverride All/g'  `grep "AllowOverride None"  -rl /etc/apache2/apache2.conf`
#重启apache
RUN /etc/init.d/apache2 restart
#清空apache默认目录文件
RUN rm -rf /var/www/html/* 
#复制代码到目录
COPY . /var/www/html
#修改目录下所有文件的读写权限为777
RUN chmod -R 777 /var/www/html
#工作目录，下面的run和 cmd 等命令的目录
WORKDIR /var/www/html
RUN chmod 755 ./start.sh
#开启端口
EXPOSE 80
CMD ["./start.sh"]
