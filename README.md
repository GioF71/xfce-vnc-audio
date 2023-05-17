# xfce-vnc-audio

A docker container for xfce4 via vnc for audio playback, possibly through upnp/dlna with pulseaudio-dlna.  
The Chromium browser is installed, as well as an Upnp Control Point ([upplay](https://www.lesbonscomptes.com/upplay/index.html)).  
PulseAudio-DLNA is also installed, so you will be able to `cast` audio (e.g.) from SoundCloud on the browser to your existing dlna renderers. You can set up your own renderer with docker using a combination of [mpd](https://github.com/GioF71/mpd-alsa-docker) and [upmpdcli](https://github.com/GioF71/upmpdcli-docker).

## Disclaimer

This is a *work in progress*. It is only working correctly on the amd64 platform. On arm, I cannot find a way to make it work correctly due to missing fonts. If anybody knows how to correct this, please create and issue or a discussion.  

## Links

Repo|URL
:---|:---
Source code|[GitHub](https://github.com/GioF71/xfce-vnc-audio)
Docker images|[Docker Hub](https://hub.docker.com/r/giof71/xfce-vnc-audio)

## Usage

### Environment Variables

VARIABLE|DESCRIPTION
:---|:---
PUID|User id for the user `vnc-user`, defaults to `1000`
PGID|Group id for the group `vnc-user`, defaults to `1000`
AUDIO_GID|`audio` group id from the host machine.
VNC_EXPOSE|Set to `yes` if you want to expose VNC directly (not recommended). If exposed, the port is 5901.
VNC_GEOMETRY|Geometry of vnc, defaults to `1280x720`
VNC_DEPTH|Color depth of vnc, defaults to `16`, conservatively
VNC_AUTOSTART_PULSEAUDIO|Autostart PulseAudio, defaults to `yes`
VNC_AUTOSTART_PULSEAUDIO_DLNA|Autostart PulseAudio-DLNA, defaults to `yes`

### Volumes

VOLUME|DESCRIPTION
:---|:---
/home/vnc-user|Home directory, use if you want to maintain your configurations.

### Ports

PORT|DESCRIPTION
:---|:---
6080|Port of NOVnc. Connect to `http://<host>:6080/vnc.html`
5901|Port of VNC, available if VNC_EXPOSE is set to `yes`

### Examples

#### Docker Run

```text
 docker run \
    --rm \
    -it \
    --name xfce-vnc-audio \
    --network host \
    -e AUDIO_GID=995 \
    -p 6080:6080 \
    giof71/xfce-vnc-audio:local-bullseye
```

Check what is the gid of `audio` on your system and use it instead of the `995` shown in the example.

#### Docker Compose

To be added.

## Changelog

DATE|DESCRIPTION
:---|:---
2023-04-01|Initial release for amd64 only. Not an April fool.
