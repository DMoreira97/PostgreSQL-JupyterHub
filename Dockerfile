# Create database
#FROM postgres

#ENV POSTGRES_USER docker
#ENV POSTGRES_PASSWORD docker
#ENV POSTGRES_DB docker
#COPY world.sql /docker-entrypoint-initdb.d/

# Create pgweb
FROM jupyter/minimal-notebook:latest

USER root
RUN apt-get update \
 && apt-get install -y \
    curl \
    unzip \
    wget

# install pgweb
ENV PGWEB_VERSION=0.11.6
RUN wget -q "https://github.com/sosedoff/pgweb/releases/download/v${PGWEB_VERSION}/pgweb_linux_amd64.zip" \
 && unzip pgweb_linux_amd64.zip -d /usr/bin \
 && mv /usr/bin/pgweb_linux_amd64 /usr/bin/pgweb

# install postgres
RUN apt install postgresql postgresql-contrib -y \
 && chmod +r /etc/postgresql/12/main/pg_hba.conf \
 && service postgresql start
# RUN psql --dbname=db0 --host=localhost --user=postgres --no-password --port=5432 --file=schema.sql
# && psql "dbname=db0 host=localhost user=postgres password=postgres port=5432 sslmode=require"
# && psql -h localhost -p 5432 -d database -U postgres -f schema.sql

# setup package, enable classic extension, build lab extension
USER "${NB_USER}"
WORKDIR "${HOME}"
RUN python3 -m pip install git+https://github.com/illumidesk/jupyter-pgweb-proxy.git
RUN jupyter serverextension enable --sys-prefix jupyter_server_proxy

# copy configs, update permissions as root
USER root
RUN cp /etc/jupyter/jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config_base.py
COPY jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py
RUN fix-permissions /etc/jupyter

USER "${NB_USER}"