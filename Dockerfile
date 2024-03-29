ARG BASE_IMAGE="${BASE_IMAGE}"
FROM ${BASE_IMAGE} AS BASE
ARG BASE_IMAGE="${BASE_IMAGE}"
ARG USE_APT_PROXY

RUN mkdir -p /app/conf
RUN echo $BASE_IMAGE > /app/conf/base-image.txt

RUN echo "USE_APT_PROXY=["${USE_APT_PROXY}"]"

COPY app/conf/01-apt-proxy /app/conf/

RUN if [ "${USE_APT_PROXY}" = "Y" ]; then \
        echo "Builind using apt proxy"; \
        cp /app/conf/01-apt-proxy /etc/apt/apt.conf.d/01-apt-proxy; \
        cat /etc/apt/apt.conf.d/01-apt-proxy; \
    else \
        echo "Building without apt proxy"; \
    fi

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y wget

RUN apt-get update
# regular software
RUN apt-get install -y htop
RUN apt-get install -y xfce4
#RUN apt-get install -y xfce4-goodies
RUN apt-get install -y xfce4-terminal
RUN apt-get install -y xfce4-whiskermenu-plugin
RUN apt-get install -y dbus-x11
RUN update-alternatives --install /usr/bin/x-terminal-emulator \
    x-terminal-emulator /usr/bin/xfce4-terminal 50
RUN apt-get install -y tightvncserver
RUN apt-get install -y xfonts-base xfonts-100dpi xfonts-75dpi
RUN apt-get install -y novnc
RUN apt-get install -y python3-websockify
RUN apt-get install -y python3-numpy
RUN apt-get install -y pulseaudio
RUN apt-get install -y procps

RUN apt-get -y autoremove

RUN rm -rf /var/lib/apt/lists/*

RUN if [ "$USE_APT_PROXY" = "Y" ]; then \
		rm /etc/apt/apt.conf.d/01-apt-proxy; \
	fi

RUN mkdir /app/install
COPY install/install-upplay.sh /app/install/

FROM scratch
COPY --from=BASE / /

LABEL maintainer="GioF71"
LABEL source="https://github.com/GioF71/xfce-vnc-audio-docker"

RUN mkdir -p /app
RUN mkdir -p /app/assets
RUN mkdir -p /app/bin
RUN mkdir -p /app/doc

COPY app/bin/run-xfce.sh /app/bin/
COPY app/assets/* /app/assets/
RUN chmod +x /app/bin/*.sh

COPY README.md /app/doc/

ENV APT_CACHE_URL ""
ENV INSTALL_UPPLAY ""
ENV INSTALL_CHROMIUM ""
ENV INSTALL_FIREFOX ""
ENV INSTALL_PULSEAUDIO_DLNA ""
ENV INSTALL_CANTATA ""

ENV PUID ""
ENV PGID ""
ENV AUDIO_GID ""

ENV VNC_GEOMETRY ""
ENV VNC_DEPTH ""
ENV VNC_EXPOSE ""

ENV VNC_AUTOSTART_PULSEAUDIO ""
ENV VNC_AUTOSTART_PULSEAUDIO_DLNA ""
ENV VNC_PASSWORD ""

WORKDIR /app

ENTRYPOINT ["/app/bin/run-xfce.sh"]
