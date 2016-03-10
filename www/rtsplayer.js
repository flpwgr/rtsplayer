var exec = require('cordova/exec');

exports.watchVideo = function(moviePath, success, error) {
    exec(success, error, "rtsplayer", "watchVideo", [moviePath]);
};

exports.watch = function(moviePath, user, password, success, error) {
	exec(success, error, "rtsplayer", "watch", [moviePath, user, password]);
};