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

if [ ! $(getent group $GROUP_NAME) ]; then
    echo "group $GROUP_NAME does not exist, creating..."
    groupadd -g $PGID $GROUP_NAME
else
    echo "group $GROUP_NAME already exists."
fi

if [ ! $(getent passwd $USER_NAME) ]; then
    echo "user $USER_NAME does not exist, creating..."
    useradd -m --gid $PGID --uid $PGID $USER_NAME
else
    echo "user $USER_NAME already exists."
fi

if [ ! -f "$HOME_DIR/.vnc/xstartup" ]; then
    echo "Creating xstartup file..."
    mkdir $HOME_DIR/.vnc
    cp /app/assets/xstartup $HOME_DIR/.vnc/
    chown -R $USER_NAME:$GROUP_NAME $HOME_DIR/.vnc
    chmod 700 $HOME_DIR/.vnc
    chmod 755 $HOME_DIR/.vnc/xstartup
else
    echo "xstartup file already exists"
fi

#echo "Command line: [$CMD_LINE]"

myuser="vnc"
mypasswd="password"

echo $mypasswd | vncpasswd -f > $HOME_DIR/.vnc/passwd
chown -R $USER_NAME:$GROUP_NAME $HOME_DIR/.vnc
chmod 0600 $HOME_DIR/.vnc/passwd


CMD_LINE="vncserver"

su - $USER_NAME -c "$CMD_LINE"

su - $USER_NAME -c "/bin/bash"