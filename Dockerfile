FROM microsoft/dotnet:1.1.2-sdk

# get add-apt-repository
RUN apt-get update
RUN apt-get -y --no-install-recommends install software-properties-common curl apt-transport-https

# add nodejs ppa
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -

# update apt cache
RUN apt-get update

# vscode dependencies
RUN apt-get -y --no-install-recommends install libc6-dev libgtk2.0-0 libgtk-3-0 libpango-1.0-0 libcairo2 libfontconfig1 libgconf2-4 libnss3 libasound2 libxtst6 unzip libglib2.0-bin libcanberra-gtk-module libgl1-mesa-glx curl build-essential gettext libstdc++6 software-properties-common wget git xterm automake libtool autogen nodejs libnotify-bin aspell aspell-en htop git emacs mono-complete gvfs-bin libxss1 rxvt-unicode-256color x11-xserver-utils sudo vim

RUN apt-get -y install libxkbfile1

# update npm
RUN npm install npm -g

# install vscode
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
RUN mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
RUN sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

RUN apt-get update
RUN apt-get install code # or code-insiders

# install flat plat theme
RUN wget 'https://github.com/nana-4/Flat-Plat/releases/download/3.20.20160404/Flat-Plat-3.20.20160404.tar.gz'
RUN tar -xf Flat-Plat*
RUN mv Flat-Plat /usr/share/themes
RUN rm Flat-Plat*gz
RUN mv /usr/share/themes/Default /usr/share/themes/Default.bak
RUN ln -s /usr/share/themes/Flat-Plat /usr/share/themes/Default

# install hack font
RUN wget 'https://github.com/chrissimpkins/Hack/releases/download/v2.020/Hack-v2_020-ttf.zip'
RUN unzip Hack*.zip
RUN mkdir /usr/share/fonts/truetype/Hack
RUN mv Hack* /usr/share/fonts/truetype/Hack
RUN fc-cache -f -v

# create our developer user
WORKDIR /root
RUN groupadd -r developer -g 1000
RUN useradd -u 1000 -r -g developer -d /developer -s /bin/bash -c "Software Developer" developer
COPY /developer /developer
WORKDIR /developer

# default browser firefox
RUN ln -s /developer/.local/share/firefox/firefox /bin/xdg-open

# enable sudo for developer
RUN echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/developer

# fix developer permissions
RUN chmod +x /developer/bin/*
RUN chown -R developer:developer /developer

USER developer

# install firefox
RUN mkdir Applications
RUN wget "https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=fr" -O firefox.tar.bz2
# RUN wget "https://ftp.mozilla.org/pub/firefox/nightly/2016/06/2016-06-30-00-40-07-mozilla-aurora/firefox-49.0a2.en-US.linux-x86_64.tar.bz2" -O firefox.tar.bz2
RUN tar -xf firefox.tar.bz2
RUN mv firefox .local/share
RUN rm firefox.tar.bz2

USER root

# addon RVV
RUN rm /var/lib/dpkg/lock
RUN apt-get -y --no-install-recommends install \
    apt-utils \
    ca-certificates \
    curl \
    fakeroot \
    gconf2 \
    gconf-service \
    git \
    gvfs-bin \
    libasound2 \
    libcanberra-gtk-module \
    libcap2 \
    libgconf-2-4 \
    libgtk2.0-0 \
    libnotify4 \
    libnss3 \
    libxkbfile1 \
    libxss1 \
    libxtst6 \
    python \
    snap \
    wget \
    xdg-utils

USER developer

RUN code --install-extension ms-vscode.csharp
RUN code --install-extension chiehyu.vscode-astyle
RUN code --install-extension Leopotam.csharpfixformat
RUN code --install-extension jchannon.csharpextensions
RUN code --install-extension reflectiondm.classynaming
RUN code --install-extension PeterJausovec.vscode-docker
RUN code --install-extension DavidAnson.vscode-markdownlint
RUN code --install-extension DotJoshJohnson.xml
RUN code --install-extension mrmlnc.vscode-apache
RUN code --install-extension jakeboone02.cypher-query-language
RUN code --install-extension sensourceinc.vscode-sql-beautify
RUN code --install-extension jmrog.vscode-nuget-package-manager
RUN code --install-extension ms-vscode.mono-debug

# links for firefox
RUN ln -s /developer/.local/share/firefox/firefox /developer/bin/x-www-browser
RUN ln -s /developer/.local/share/firefox/firefox /developer/bin/gnome-www-browser

# copy in test project
COPY project /developer/project
WORKDIR /developer/project

# setup our ports
EXPOSE 5000
EXPOSE 3000
EXPOSE 3001

# set environment variables
ENV PATH /developer/.npm/bin:$PATH
ENV NODE_PATH /developer/.npm/lib/node_modules:$NODE_PATH
ENV BROWSER /developer/.local/share/firefox/firefox-bin
ENV SHELL /bin/bash
ENV DOTNET_SKIP_FIRST_TIME_EXPERIENCE true

USER root

# addon RVV
RUN sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ trusty main" > /etc/apt/sources.list.d/dotnetdev.list'
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893
RUN apt-get update
RUN apt-get install -y dirmngr apt-transport-https libnotify4

USER developer

# mount points
VOLUME ["/developer/.config/Code"]
VOLUME ["/developer/.vscode"]
VOLUME ["/developer/.ssh"]
VOLUME ["/developer/project"]

# start vscode
ENTRYPOINT ["/developer/bin/start-shell"]

