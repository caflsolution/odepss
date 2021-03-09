#   Nuevo Dockerfile que crea una imagen con Odoo 12 y postgresql
FROM    debian:buster

ENV     TZ=America/Santiago

#   Update system and install important dependencies 
RUN     apt update && \
        apt -y upgrade && \
        DEBIAN_FRONTEND=noninteractive apt-get install tzdata && \
        ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
        echo $TZ > /etc/timezone && \
        dpkg-reconfigure --frontend noninteractive tzdata && \
        apt -y install \
            software-properties-common \
            dirmngr \
            apt-transport-https \
            lsb-release \
            ca-certificates && \
        apt-get install -y \
            git \
            wget \
            snap \
            gdebi-core && \
        apt-get install -y \
            gnupg2 && \
        apt update && \
        apt autoremove && \
        apt clean && \
        apt autoclean

RUN     mkdir /opt/odoo && \
        mkdir /opt/odoo/config && \
        mkdir /opt/odoo/extra-addons && \
        mkdir /opt/odoo/extra-addons/localizacion && \
        mkdir /opt/odoo/extra-addons/tercero && \
        mkdir /opt/odoo/extra-addons/oca && \
        mkdir /opt/odoo/log  && \
        mkdir /opt/odoo/data 

#   Install python 3.9 
RUN     apt -y install \
            build-essential \
            zlib1g-dev \
            libncurses5-dev \
            libgdbm-dev \
            libnss3-dev \
            libssl-dev \
            libsqlite3-dev \
            libreadline-dev \
            libffi-dev \
            curl \
            libbz2-dev && \
        cd /opt/ && \
        wget https://www.python.org/ftp/python/3.9.1/Python-3.9.1.tgz && \
        tar -xf Python-3.9.1.tgz && \
        rm Python-3.9.1.tgz && \
        cd Python-3.9.1 && \
        ./configure --enable-optimizations && \
        make altinstall && \
        cd -

#   Clone repository odoo 12
RUN     git clone https://github.com/odoo/odoo.git -b 12.0 --depth 1 /opt/odoo/12/odoo && \
        git clone https://github.com/odooerpdevelopers/backend_theme.git -b 12.0 --depth 1 /opt/odoo/extra-addons/tercero/backend_theme && \
        git clone https://github.com/oca/web.git -b 12.0 --depth 1 /opt/odoo/extra-addons/oca/web

#   Install Dependencies python
RUN     apt install python3-pip -y && \
        apt install python3-setuptools && \
        pip3 install \
            psycopg2-binary \
            Werkzeug \
            PyPDF2 \
            python-dateutil==2.8.1 \
            setuptools \
            psutil \
            babel \
            jinja2 \
            reportlab \
            passlib \
            python-openid \
            six \
            PyYAML \
            tz \
            vatnumber \
            build \
            python-webdav \
            webdav \
            mock==1.0.1 \
            decorator \
            polib \
            gdata pytz==2019.1 \
            psycogreen \
            unittest2 \
            pysftp \
            queues \
            pyzbar \
            queuelib \
            pdf2image \
            openupgradelib \
            suds-jurko \
            python-barcode \
            Rust && \
        pip3 install --upgrade pip && \
        pip3 install \
            pyOpenSSL \
            requests \
            xmltodict \
            PyQRCode \
            pypng \
            xades \
            pandas

#   Install Wkhtmltopdf and library
RUN     apt-get -y install \
            libxrender1 \
            xfonts-encodings \
            xfonts-utils \
            fontconfig \
            fontconfig-config \
            pkg-config \
            xfonts-base \
            xfonts-75dpi \
            liblcms2-2 \
            zlib1g \
            libxslt1.1 \
            libtiff5 && \
        wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_amd64.deb && \
        dpkg -i --force-depends wkhtmltox_0.12.6-1*.deb && \
        apt-get -f -y install && \
        ln -s /usr/local/bin/wkhtml* /usr/bin && \
        rm -rf wkhtmltox*.deb && \
        apt-get -f -y install


#   install node
RUN     cd ~ && \
        curl -sL https://deb.nodesource.com/setup_15.x -o nodesource_setup.sh && \
        touch nodesource_setup.sh && \
        bash nodesource_setup.sh && \
        apt install -y \
            node-less \
            node-clean-css && \
        rm -rf /usr/bin/lessc && \
        npm install -g less && \
        npm install -g less-plugin-clean-css && \
        npm install -g rtlcss

#   install python requirements file (Odoo)
RUN     sed -i '/pyldap==2.4.28/d' /opt/odoo/12/odoo/requirements.txt && \
        sed -i '/python-ldap==3.1.0/d' /opt/odoo/12/odoo/requirements.txt && \
        sed -i '/python-stdnum==1.8/d' /opt/odoo/12/odoo/requirements.txt && \
        sed -i '/Pillow==5.4.1/d' /opt/odoo/12/odoo/requirements.txt && \
        sed -i '/Pillow==6.1.0/d' /opt/odoo/12/odoo/requirements.txt && \
        sed -i '/psycopg2==2.7.3.1/d' /opt/odoo/12/odoo/requirements.txt && \
        sed -i '/psycopg2==2.8.3/d' /opt/odoo/12/odoo/requirements.txt && \
        sed -i '/psycopg2==2.8.5/d' /opt/odoo/12/odoo/requirements.txt && \
        sed -i '/lxml==3.7.1/d' /opt/odoo/12/odoo/requirements.txt && \
        sed -i '/lxml==4.2.3/d' /opt/odoo/12/odoo/requirements.txt && \
        sed -i '/lxml==4.3.2/d' /opt/odoo/12/odoo/requirements.txt && \
        sed -i '/pytz==2016.7/d' /opt/odoo/12/odoo/requirements.txt && \
        sed -i '/python-dateutil==2.5.3/d' /opt/odoo/12/odoo/requirements.txt && \
        pip3 install -r /opt/odoo/12/odoo/requirements.txt && \
        apt --fix-broken install && \
        apt-get -f -y install

VOLUME  ["/opt/odoo/log","/opt/odoo/data","/opt/odoo/config", "/opt/odoo/extra-addons"]

EXPOSE  8069 80

CMD     ["/bin/bash"]
