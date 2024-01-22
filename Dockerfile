FROM debian:buster
LABEL maintainer="Artem Kiselev <lanolin652@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive

RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections && \
    echo "deb http://ftp.ru.debian.org/debian buster main contrib" >> /etc/apt/sources.list.d/contrib.list && \
    apt-get update && \ 
    apt-get install -qy --reinstall \
        make git ca-certificates wget curl unzip \
        apt-transport-https \
        ttf-mscorefonts-installer \ 
        texlive-base \
        texlive-extra-utils \
        texlive-fonts-extra \
        texlive-formats-extra \
        texlive-lang-english texlive-lang-cyrillic \
        texlive-latex-base \
        texlive-latex-extra \
        texlive-latex-recommended \
        texlive-pictures \
        texlive-science \
        texlive-xetex \
        latexmk && \
        apt-get autoclean && \
        apt-get --purge --yes autoremove && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# texlive \
# texlive-bibtex-extra \
# texlive-binaries \
# texlive-font-utils \
# texlive-fonts-recommended \
# texlive-generic-extra \
# texlive-generic-recommended \
# texlive-humanities \
# texlive-plain-generic \
# texlive-publishers \

RUN wget -O /tmp/anonym.zip http://webfonts.ru/original/anonym/anonym.zip && \
    unzip -o /tmp/anonym.zip -d /usr/share/fonts/ && \
    rm -f /tmp/anonym.zip && \
    fc-cache -f -v

RUN wget -O /tmp/gost.zip https://master.dl.sourceforge.net/project/biblatexgost/ver.1.22/biblatex-gost-1.22.tds.zip && \
	unzip -o /tmp/gost.zip -d /usr/share/texmf-dist/ && \
	rm -f /tmp/gost.zip && \
	mktexlsr


WORKDIR /build
VOLUME [ "/build" ]