# xfce-vnc-audio

A docker container for xfce4 via vnc for audio playback, possibly through upnp/dlna with pulseaudio-dlna.  
The Firefox browser is installed, as well as an Upnp Control Point ([upplay](https://www.lesbonscomptes.com/upplay/index.html)).  

## Disclaimer

This is a work in progress. It is only working correctly on the amd64 platform.

## Usage

### Environment Variables

VARIABLE|DESCRIPTION
:---|:---
PUID|User id for the user `vnc-user`, defaults to `1000`
PGID|Group id for the group `vnc-user`, defaults to `1000`
AUDIO_GID|`audio` group id from the host machine.
VNC_EXPOSE|Set to `yes` if you want to expose VNC directly (not recommended)
VNC_GEOMETRY|Geometry of vnc, defaults to `1280x720`
VNC_DEPTH|Color depth of vnc, defaults to `16`, conservatively
VNC_AUTOSTART_PULSEAUDIO|Autostart PulseAudio, defaults to `yes`
VNC_AUTOSTART_PULSEAUDIO_DLNA|Autostart PulseAudio-DLNA, defaults to `yes`

### Volumes

VOLUME|DESCRIPTION
:---|:---
/home/vnc-user|Home directory, use if you want to maintain your configurations.

## Changelog

DATE|DESCRIPTION
:---|:---
**unknown**|Initial release