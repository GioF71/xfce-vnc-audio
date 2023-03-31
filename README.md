# xfce-vnc-audio

A docker container for xfce4 via vnc for audio playback, possibly through upnp/dlna with pulseaudio-dlna.  
The Firefox browser is installed, as well as an Upnp Control Point ([upplay](https://www.lesbonscomptes.com/upplay/index.html)).  

## Usage

### Environment Variables

VARIABLE|DESCRIPTION
:---|:---
PUID|User id for the user `vnc-user`
PGID|Group id for the group `vnc-user`
VNC_GEOMETRY|Geometry of vnc, defaults to `1280x720`
VNC_DEPTH|Color depth of vnc, defaults to `16`, conservatively
VNC_AUTOSTART_PULSEAUDIO|Autostart PulseAudio, defaults to `yes`
VNC_AUTOSTART_PULSEAUDIO_DLNA|Autostart PulseAudio-DLNA, defaults to `yes`

### Volumes

## Changelog