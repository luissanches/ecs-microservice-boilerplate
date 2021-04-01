const { logger, envs } = require('@1edge-backend/common-lib');
const express = require('express');
const app = express();
const serverRoutes = require('./server.routes');
const package = require('../package.json');
const cors = require('cors');
const helmet = require('helmet');

logger.info(`####  Microservice ${package.name} is starting...  ####`)

app.use(cors());
app.use(helmet());
app.use(express.urlencoded({ extended: false }));
app.use(express.json());

serverRoutes.applyLog(app);
serverRoutes.applyAuthorization(app);
serverRoutes.configureRoutes(app);


if (envs.NODE_ENV !== 'test') {
  app.listen(envs.PORT || 3001, (err) => {
    if (err) {
      logger.error(err.message)
      process.exit(1);
    } else {
      logger.info(`Http server env ${envs.NODE_ENV || 'NODE_ENV not configured...'} and listening on ${envs.PORT}`)
    }
  });
}
// Used by Mocha Tests
module.exports = app;