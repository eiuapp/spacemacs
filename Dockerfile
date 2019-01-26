FROM spacemacs/emacs25:develop

MAINTAINER JAremko <w3techplaygound@gmail.com>

ENV UNAME="jare"

ENV CHROME_KEY="https://dl-ssl.google.com/linux/linux_signing_key.pub" \
    CHROME_REP="deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"

RUN apt-get update \
    && apt-get install \
    gcc \
    curl \
    rlwrap \
    silversearcher-ag \
    wget \
    && wget -q -O - "${CHROME_KEY}" | apt-key add - \
    && echo "${CHROME_REP}" >> /etc/apt/sources.list.d/google.list \
    && apt-get update \
    && apt-get install 	google-chrome-stable \
    && rm -rf /tmp/* /var/lib/apt/lists/* \
    && google-chrome \
    --disable-gpu \
    --headless \
    --no-sandbox \
    https://example.org/

COPY .spacemacs "${UHOME}/.spacemacs"
COPY private "${UHOME}/.emacs.d/private"
COPY .lein "${UHOME}/.lein"

# Install Spacemacs layers dependencies and init user
RUN install-deps

USER $UNAME

RUN emacs --batch -u $UNAME \
    --eval="(require 'emacsql-sqlite)" \
    --eval="(emacsql-sqlite-compile)"

RUN git config --global user.name JAremko \
    && git config --global user.email w3techplayground@gmail.com

RUN echo "(defproject stub \"0.0.1-SNAPSHOT\")" > /tmp/project.clj \
    && cd /tmp/ \
    && lein deps \
    && rm -rf /tmp/*
USER root
