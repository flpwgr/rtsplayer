var exec = require('cordova/exec');

exports.watchVideo = function(moviePath, success, error) {
    exec(success, error, "rtsplayer", "watchVideo", [moviePath]);
};
