# rtsplayer
a very, very, very, very simple rtsp player using FFMpeg and ImageView.


## Install

```cordova plugin add https://github.com/felipew/rtsplayer.git```

Execute the compile.sh inside the Plugins folder

Now you are ready to go

## Using

``` javascript
cordova.plugins.rtsplayer.watchVideo("rtsp://10.0.0.100:554/video", callbackSucces, callbackError);
```

## Contribute

Android version is missing :(


## About

This plugin was origanly created to be used with h.264 rtsp streams.
