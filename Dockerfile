FROM python:3.8.20-slim-bullseye

COPY *.txt /opt/app/

RUN apt update \
    && apt-get install wget gnupg -y \
    && sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt-get update \
    && apt-get install postgresql-client-14 -y \
    && apt-get install -y libldap2-dev libsasl2-dev \
    && apt-get install libpq-dev -y

RUN xargs apt install < /opt/app/aptrequirements.txt \
--no-install-recommends -y \
    && wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb \
    && dpkg -i wkhtmltox_0.12.5-1.stretch_amd64.deb \
    && rm wkhtmltox_0.12.5-1.stretch_amd64.deb \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip setuptools==57.5.0 wheel --no-cache \
    && pip3 install -r /opt/app/requirements.txt --no-cache-dir 

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales

RUN adduser --system --quiet --shell=/bin/bash --home=/odoo --gecos 'ODOO' --group odoo

ADD odoo.conf /etc/odoo/odoo.conf

COPY entrypoint.sh /entrypoint.sh

RUN mkdir /var/log/odoo /bradoo_addons /var/lib/odoo \
    && chown odoo:odoo /var/log/odoo /bradoo_addons /etc/odoo/odoo.conf /var/lib/odoo \
    && chmod 640 /etc/odoo/odoo.conf \
    && chmod +x /entrypoint.sh

EXPOSE 8069 8072
 
ENV ODOO_RC=/etc/odoo/odoo.conf PATH="/odoo:${PATH}"

ENTRYPOINT ["/entrypoint.sh"]

CMD ["odoo-bin","-c","/etc/odoo/odoo.conf"]
