var exec = require('cordova/exec');

module.exports = {
  exitApp: function () {
    exec(null, null, 'OsxUtils', 'exitApp', []);
  },
  openUrl: function (url, success, fail) {
    exec(success, fail, 'OsxUtils', 'openUrl', [url]);
  },  
  resize: function (fullscreen, rect, flags, success, fail) {
    exec(success, fail, 'OsxUtils', 'resize', [fullscreen, rect && JSON.stringify(rect), flags && JSON.stringify(flags)]);
  }
};
