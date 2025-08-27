FROM alpine:latest

LABEL maintainer="Wishmasterflo"

RUN apk add --no-cache sudo git xfce4 faenza-icon-theme bash python3 tigervnc xfce4-terminal firefox cmake wget \
    pulseaudio xfce4-pulseaudio-plugin pavucontrol pulseaudio-alsa alsa-plugins-pulse alsa-lib-dev nodejs npm \
    build-base \
    && adduser -h /home/alpine -s /bin/bash -S -D alpine && echo -e "alpine\nalpine" | passwd alpine \
    && echo 'alpine ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && git clone https://github.com/novnc/noVNC /opt/noVNC \
    && git clone https://github.com/novnc/websockify /opt/noVNC/utils/websockify

# Copy local files instead of downloading from remote
COPY script.js /opt/noVNC/script.js
COPY audify.js /opt/noVNC/audify.js
COPY vnc.html /opt/noVNC/vnc.html
COPY pcm-player.js /opt/noVNC/pcm-player.js

# Environment variables for ports
ENV NOVNC_PORT=6080
ENV AUDIO_PORT=50160
ENV VNC_PORT=5999

RUN npm install --prefix /opt/noVNC ws
RUN npm install --prefix /opt/noVNC audify

USER alpine
WORKDIR /home/alpine

RUN mkdir -p /home/alpine/.vnc \
    && echo -e "-Securitytypes=none" > /home/alpine/.vnc/config \
    && echo -e "#!/bin/bash\nstartxfce4 &" > /home/alpine/.vnc/xstartup \
    && echo -e "alpine\nalpine\nn\n" | vncpasswd

USER root

RUN echo '\
#!/bin/bash \
/usr/bin/vncserver :99 2>&1 | sed  "s/^/[Xtigervnc ] /" & \
sleep 1 & \
/usr/bin/pulseaudio 2>&1 | sed  "s/^/[pulseaudio] /" & \
sleep 1 & \
AUDIO_PORT=${AUDIO_PORT} /usr/bin/node /opt/noVNC/audify.js 2>&1 | sed "s/^/[audify    ] /" & \
/opt/noVNC/utils/novnc_proxy --listen 0.0.0.0:${NOVNC_PORT} --vnc localhost:${VNC_PORT} 2>&1 | sed "s/^/[noVNC     ] /"'\
>/entry.sh

USER alpine

ENTRYPOINT [ "/bin/bash", "/entry.sh" ]
