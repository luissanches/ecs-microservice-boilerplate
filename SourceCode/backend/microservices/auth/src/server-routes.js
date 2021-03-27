const { authMiddleware, coreDB, helper, logger, envs } = require('@1edge-backend/common-lib');
const authRoute = require('./auth.route');
const package = require('../package.json');

let EXCEPTION_ROUTES = ['/v1/auth', '/isalive', '/v1/auth/ping'];

exports.configureRoutes = fastify => {
  for (let method in authRoute) {
    fastify.route(authRoute[method]);
  }
  fastify.route(isAliveRoute);
};

exports.applyAuthorization = fastify => {
  fastify.addHook('preHandler', (request, reply, done) => {
    if (envs.AUTH_ENABLED === 'true') {
      EXCEPTION_ROUTES.includes(request.raw.url) ? done() : authMiddleware.verifyJWT(request, reply, done);
    }
    else {
      done();
    }
  });
};

exports.applyLog = fastify => {
  fastify.addHook('preHandler', (request, reply, done) => {
    logger.info(`request incoming from ${request.ip} - to ${package.name} - method: ${request.raw.method} - hostname: ${request.raw.hostname} - url: ${request.raw.url}`)
    done()
  });
};

const isAliveRoute = {
  method: 'GET',
  url: '/isalive',
  schema: {},
  handler: async (request, reply) => {
    try {
      let mongo_db = await coreDB.checkConnection() || '-';
      let node_env = envs.NODE_ENV || '-';
      logger.info('isalive called has called')
      reply.send(helper.makeDefaultResponse({ service: package.name, ready: true, version: package.version, mongo_db, node_env }));
    } catch (err) {
      reply.send(helper.makeDefaulErrortResponse(err.message));
    }
  }
};

