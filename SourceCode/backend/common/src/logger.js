const log4js = require('log4js');

log4js.configure({
  appenders: {
    out: { type: 'stdout' },
    console: { type: 'console' },
    app: { type: 'file', filename: process.env.LOGGER_PATH }
  },
  categories: {
    default: { appenders: ['out', 'app', 'console'], level: 'debug' },
    yoston: { appenders: ['app', 'console'], level: 'debug' }
  }
});

const logger = log4js.getLogger('1Edge');

module.exports = {
  logger
}