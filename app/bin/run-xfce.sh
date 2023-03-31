#!/bin/bash

echo "Run XFCE"

echo "Creating user ...";
DEFAULT_UID=1000
DEFAULT_GID=1000
if [ -z "${PUID}" ]; then
    PUID=$DEFAULT_UID;
    echo "Setting default value for PUID: ["$PUID"]"
fi
if [ -z "${PGID}" ]; then
    PGID=$DEFAULT_GID;
    echo "Setting default value for PGID: ["$PGID"]"
fi

USER_NAME=vnc-user
GROUP_NAME=vnc-user
HOME_DIR=/home/$USER_NAME

if [[ -d "$HOME_DIR" ]]; then
    echo "Home directory [$HOME_DIR] already exists, setting ownership"
    chown -R $PUID:$PGID $HOME_DIR
else
    echo "Home directory [$HOME_DIR] does not exist, will be created"
fi

if [ ! $(getent group $GROUP_NAME) ]; then
    echo "group $GROUP_NAME does not exist, creating..."
    groupadd -g $PGID $GROUP_NAME
else
    echo "group $GROUP_NAME already exists."
fi

if [ ! $(getent passwd $USER_NAME) ]; then
    echo "user $USER_NAME does not exist, creating..."
    useradd -m -s /bin/bash --gid $PGID --uid $PGID $USER_NAME
else
    echo "user $USER_NAME already exists."
fi

if [ -n ${AUDIO_GID} ]; then
    if [ $(getent group $AUDIO_GID) ]; then
        echo "  Group with gid $AUDIO_GID already exists"
    else
        echo "  Creating group with gid $AUDIO_GID"
        groupadd -g $AUDIO_GID vnc_user_audio
    fi
    echo "  Adding $USER_NAME to gid $AUDIO_GID"
    AUDIO_GRP=$(getent group $AUDIO_GID | cut -d: -f1)
    echo "  gid $AUDIO_GID -> group $AUDIO_GRP"
    if id -nG "$USER_NAME" | grep -qw "$AUDIO_GRP"; then
        echo "  User $USER_NAME already belongs to group audio (GID ${AUDIO_GID})"
    else
        usermod -a -G $AUDIO_GRP $USER_NAME
        echo "  Successfully added $USER_NAME to group audio (GID ${AUDIO_GID})"
    fi
fi

cd $HOME_DIR

if [ ! -f "$HOME_DIR/.vnc/xstartup" ]; then
    echo "Creating xstartup file..."
    mkdir $HOME_DIR/.vnc
    chown -R $USER_NAME:$GROUP_NAME $HOME_DIR/.vnc
    chmod 700 $HOME_DIR/.vnc
    chmod 755 $HOME_DIR/.vnc/xstartup
else
    echo "xstartup file already exists"
fi

# PulseAudio
#PULSE_CLIENT_CONF="/etc/pulse/client.conf"
#echo "Creating pulseaudio configuration file $PULSE_CLIENT_CONF..."
#cp /app/assets/pulse-client-template.conf $PULSE_CLIENT_CONF
#sed -i 's/PUID/'"$PUID"'/g' $PULSE_CLIENT_CONF


#echo "Command line: [$CMD_LINE]"

DEFAULT_PASSWORD="password"

if [[ -z "${VNC_PASSWORD}" ]]; then
    VNC_PASSWORD=$DEFAULT_PASSWORD
fi

echo $VNC_PASSWORD | vncpasswd -f > $HOME_DIR/.vnc/passwd
chown -R $USER_NAME:$GROUP_NAME $HOME_DIR/.vnc
chmod 0600 $HOME_DIR/.vnc/passwd

#certificate

CERT_DIR=$HOME_DIR/certificate
if [[ -d "$CERT_DIR" ]]; then
    echo "Certificate directory [$CERT_DIR] already exists, setting ownership"
    chown -R $USER_NAME:$GROUP_NAME $CERT_DIR
else
    echo "Home directory [$CERT_DIR] does not exist, will be created"
    mkdir -p $CERT_DIR
    chown -R $USER_NAME:$GROUP_NAME $CERT_DIR
fi

CMD_LINE="openssl req -x509 -nodes -newkey rsa:3072 -keyout $CERT_DIR/novnc.pem -out $CERT_DIR/novnc.pem -days 3650 -subj '/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com'"
su - $USER_NAME -c "$CMD_LINE"

DEFAULT_GEOMETRY=1280x720
DEFAULT_DEPTH=16

if [[ -z "${VNC_GEOMETRY}" ]]; then
    VNC_GEOMETRY=$DEFAULT_GEOMETRY
fi

if [[ -z "${VNC_DEPTH}" ]]; then
    VNC_DEPTH=$DEFAULT_DEPTH
fi

mkdir -p $HOME_DIR/.config/autostart
chown -R $USER_NAME:$GROUP_NAME $HOME_DIR

#prepare xstartup
echo "#!/bin/bash" > $HOME_DIR/xstartup
echo "xrdb $HOME/.Xresources" >> $HOME_DIR/xstartup
echo "startxfce4 &" >> $HOME_DIR/xstartup
chown -R $USER_NAME:$GROUP_NAME $HOME_DIR/xstartup
chmod 755 $HOME_DIR/xstartup

if [[ -z "${START_PULSEAUDIO}" || "${START_PULSEAUDIO^^}" == "YES" ]]; then
    echo "Enabling PulseAudio autostart"
    cat /app/assets/01-PulseAudio.desktop > $HOME_DIR/.config/autostart/01-PulseAudio.desktop
    chown $USER_NAME:$GROUP_NAME $HOME_DIR/.config/autostart/01-PulseAudio.desktop
    cat $HOME_DIR/.config/autostart/01-PulseAudio.desktop
else
    echo "NOT Enabling PulseAudio autostart"
fi

if [[ -z "${START_PULSEAUDIO_DLNA}" || "${START_PULSEAUDIO_DLNA^^}" == "YES" ]]; then
    echo "Enabling PulseAudio-DLNA autostart"
    cat /app/assets/02-PulseAudio-DLNA.desktop > $HOME_DIR/.config/autostart/02-PulseAudio-DLNA.desktop
    chown $USER_NAME:$GROUP_NAME $HOME_DIR/.config/autostart/02-PulseAudio-DLNA.desktop
    cat $HOME_DIR/.config/autostart/02-PulseAudio-DLNA.desktop
else
    echo "NOT Enabling PulseAudio-DLNA autostart"
fi

CMD_LINE="vncserver -depth ${VNC_DEPTH} -geometry ${VNC_GEOMETRY}"
echo "Running vncserver: [$CMD_LINE]"
su - $USER_NAME -c "$CMD_LINE"

# run novnc
CMD_LINE="websockify --web=/usr/share/novnc/ --cert=$CERT_DIR/novnc.pem 6080 localhost:5901"
su - $USER_NAME -c "$CMD_LINE"
