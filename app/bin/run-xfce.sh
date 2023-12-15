#!/bin/bash

set -ex

# exit codes
# 1 invalid argument

files_to_delete=("/tmp/.X1-lock" "/tmp/.X11-unix/X1")
dirs_to_delete=("/tmp/.X11-unix")

# cleanup
for file_to_delete in "${files_to_delete[@]}"
do
    if [ -f "$file_to_delete" ]; then
        echo "Deleting file ${file_to_delete} ..."
        rm ${file_to_delete}
        echo ". done."
    fi
done

for dir_to_delete in "${dirs_to_delete[@]}"
do
    if [ -d "$dir_to_delete" ]; then
        echo "Deleting directory ${dir_to_delete} ..."
        rm -rf ${dir_to_delete}
        echo ". done."
    fi
done

APT_CACHE_FILE="/etc/apt/apt.conf.d/01proxy"

if [ -n "${APT_CACHE_URL}" ]; then
    if [ -f "${APT_CACHE_FILE}" ]; then
        echo "Removing existing $APT_CACHE_FILE ..."
        rm $APT_CACHE_FILE
        echo ". done"
    fi
    echo "Setting apt cache"
    echo "Acquire::http::proxy \"${APT_CACHE_URL}\";" >> "${APT_CACHE_FILE}"
    echo "Acquire::https::proxy \"DIRECT\";" >> "${APT_CACHE_FILE}"
    echo "Apt cache set"
    cat "${APT_CACHE_FILE}"
fi

# PulseAudio
PULSE_CLIENT_CONF="/etc/pulse/client.conf"
echo "Creating pulseaudio configuration file $PULSE_CLIENT_CONF..."
cp /app/assets/pulse-client-template.conf $PULSE_CLIENT_CONF
sed -i 's/PUID/'"$PUID"'/g' $PULSE_CLIENT_CONF
auto_spawn=no
if [[ -n "${PULSEAUDIO_AUTOSPAWN}" ]]; then
    if [[ "${PULSEAUDIO_AUTOSPAWN^^}" == "YES" || "${PULSEAUDIO_AUTOSPAWN^^}" == "Y" ]]; then
        auto_spawn=yes
    elif [[ ! ("${PULSEAUDIO_AUTOSPAWN^^}" == "NO" || "${PULSEAUDIO_AUTOSPAWN^^}" == "N") ]]; then
        echo "Invalid PULSEAUDIO_AUTOSPAWN=[${PULSEAUDIO_AUTOSPAWN}]"
        exit 1
    fi
fi
sed -i 's/PULSEAUDIO_AUTOSPAWN/'"$auto_spawn"'/g' $PULSE_CLIENT_CONF

if [[ "${INSTALL_ALSA^^}" == "YES" || "${INSTALL_ALSA^^}" == "Y" ]]; then
    echo "Installing Alsa support ..."
    apt-get update
    apt-get -y install libasound2 alsa-utils apulse
    echo "Installed Alsa support"
elif [[ ! (-z "${INSTALL_ALSA}" || "${INSTALL_ALSA^^}" == "NO" || "${INSTALL_ALSA^^}" == "N") ]]; then
    echo "Invalid INSTALL_ALSA=[${INSTALL_ALSA}]"
    exit 1
else    
    echo "Not installing Alsa support"
fi

if [[ -z "${INSTALL_PULSEAUDIO}" || ("${INSTALL_PULSEAUDIO^^}" == "YES" || "${INSTALL_PULSEAUDIO^^}" == "Y") ]]; then
    echo "Installing PulseAudio ..."
    apt-get update
    apt-get -y install pulseaudio
    echo "Installed PulseAudio"
elif [[ ! ("${INSTALL_PULSEAUDIO^^}" == "NO" || "${INSTALL_PULSEAUDIO^^}" == "N") ]]; then
    echo "Invalid INSTALL_PULSEAUDIO=[${INSTALL_PULSEAUDIO}]"
    exit 1
else    
    echo "Not installing PulseAudio"
fi

if [ "${INSTALL_UPPLAY^^}" == "YES" ]; then
    echo "Installing upplay ..."
    /bin/bash /app/install/install-upplay.sh
    echo "Installed upplay"
else    
    echo "Not installing upplay"
fi

if [ "${INSTALL_CANTATA^^}" == "YES" ]; then
    echo "Installing Cantata ..."
    apt-get update
    apt-get -y install cantata
    echo "Installed Cantata"
else    
    echo "Not installing Cantata"
fi

if [ "${INSTALL_PULSEAUDIO_DLNA^^}" == "YES" ]; then
    echo "Installing pulseaudio-dlna ..."
    apt-get update
    apt-get -y install pulseaudio-dlna
    echo "Installed pulseaudio-dlna"
else    
    echo "Not installing pulseaudio-dlna"
fi

if [ "${INSTALL_CHROMIUM^^}" == "YES" ]; then
    echo "Installing chromium ..."
    apt-get update
    apt-get -y install chromium
    echo "Installed chromium"
else    
    echo "Not installing chromium"
fi

if [ "${INSTALL_FIREFOX^^}" == "YES" ]; then
    echo "Installing Firefox ..."
    apt-get update
    apt-get -y install firefox-esr
    echo "Installed Firefox"
else    
    echo "Not installing Firefox"
fi

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

if [ -n "${AUDIO_GID}" ]; then
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
    #prepare xstartup
    echo "#!/bin/bash" > $HOME_DIR/.vnc/xstartup
    echo "xrdb \$HOME/.Xresources" >> $HOME_DIR/.vnc/xstartup
    echo "startxfce4 &" >> $HOME_DIR/.vnc/xstartup
    chown -R $USER_NAME:$GROUP_NAME $HOME_DIR/.vnc/xstartup
    chmod 755 $HOME_DIR/.vnc/xstartup
else
    echo "xstartup file already exists"
fi

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

EXPOSE="no"

if [[ -n "${VNC_EXPOSE}" ]]; then
    if [[ "${VNC_EXPOSE^^}" == "YES" ]]; then
        EXPOSE="yes"
    elif [[ ! "${VNC_EXPOSE^^}" == "NO" ]]; then
        echo "Invalid value for VNC_EXPOSE [${VNC_EXPOSE}], leaving not exposed"
    fi
fi

CMD_LINE="vncserver"
if [ "${EXPOSE}" == "no" ]; then
    echo "VNC not exposed"
    CMD_LINE="$CMD_LINE -localhost"
else
    echo "VNC is exposed"
fi
CMD_LINE="$CMD_LINE -depth ${VNC_DEPTH} -geometry ${VNC_GEOMETRY}"
echo "Running vncserver: [$CMD_LINE]"
su - $USER_NAME -c "$CMD_LINE"

# run novnc
CMD_LINE="websockify --web=/usr/share/novnc/ --cert=$CERT_DIR/novnc.pem 6080 localhost:5901"
su - $USER_NAME -c "$CMD_LINE"
