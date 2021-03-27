const { logger, envs } = require('@1edge-backend/common-lib');

const fastify = require('fastify')();
const serverRoutes = require('./server-routes');
const package = require('../package.json');

logger.info(`###########  Microservice ${package.name} is starting  ###########`)

fastify.register(require('fastify-cors'));
fastify.register(require('fastify-helmet'));

serverRoutes.configureRoutes(fastify);
serverRoutes.applyAuthorization(fastify);
serverRoutes.applyLog(fastify);

if (envs.NODE_ENV !== 'test') {
  fastify.listen(envs.AUTH_PORT || 3001, '0.0.0.0', (err) => {
    if (err) {
      logger.error(err.message)
      process.exit(1);
    } else {
      logger.info(`Http server env ${envs.NODE_ENV || 'NODE_ENV not configured...'} and listening on ${fastify.server.address().port}`)
    }
  });
}

module.exports = fastify;