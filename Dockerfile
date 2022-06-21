# Base image https://hub.docker.com/u/rocker/
FROM rocker/geospatial

MAINTAINER "Nishna Ajmal" nishna.ajmal555@gmail.com

### shiny
RUN export ADD=shiny

# system libraries of general use
## install debian packages
#RUN add-apt-repository ppa:ubuntugis/ppa
RUN apt-get update -qq \
   && apt-get -y --no-install-recommends install \
      sudo \
      gdebi-core \
      pandoc \
      pandoc-citeproc \
      libcurl4-gnutls-dev \
      libcairo2-dev \
      libsqlite3-dev \
      libpq-dev \
      libssl-dev \
      libssh2-1-dev \
      unixodbc-dev \
      libxt-dev \
      xtail \
      wget \
      libxml2-dev \
      libfontconfig1-dev \
      libudunits2-dev \
   &&install2.r --error --skipinstalled --deps TRUE \
      devtools \
      formatR \
      remotes \
      selectr \
      caTools


## update shiny
RUN wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    . /etc/environment && \
    R -e "install.packages(c('shiny', 'rmarkdown'), repos='$MRAN')" && \
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/ && \
    chown shiny:shiny /var/lib/shiny-server

## update system libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean

# copy necessary files
## renv.lock file
COPY /example-app/renv.lock ./renv.lock
## app folder
#COPY /example-app ./app

# install renv & restore packages
RUN Rscript -e 'install.packages("renv")'
RUN Rscript -e 'renv::restore()'

# expose port
#EXPOSE 3838

#COPY shiny-server.sh /usr/bin/shiny-server.sh

#CMD ["/usr/bin/shiny-server.sh"]

# run app on container start
#CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3838)"]
