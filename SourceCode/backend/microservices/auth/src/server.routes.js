const { authMiddleware, logger, envs, helper, coreDB } = require('@1edge-backend/common-lib');
const serviceRoutes = require('./service.routes');
const package = require('../package.json');
let router = require('express').Router();

let OPENED_ROUTES = ['/', `/v1/${package.name}/isalive`, `/v1/${package.name}/ping`];

exports.configureRoutes = app => {
  router.get(`/v1/${package.name}/isalive`, async (req, res) => {
    try {
      let mongo_db = await coreDB.checkConnection() || '-';
      let node_env = envs.NODE_ENV || '-';
      logger.info('isalive called has called')
      res.send(helper.makeDefaultResponse({ service: package.name, ready: true, version: package.version, mongo_db, node_env }));
    } catch (err) {
      res.send(helper.makeDefaulErrortResponse(err.message));
    }
  });
  serviceRoutes.setRoutes(router);
  app.use(router);
};

exports.applyAuthorization = app => {
  app.use((req, res, next) => {
    if (envs.AUTH_ENABLED === 'true') {
      OPENED_ROUTES.includes(req._parsedUrl.pathname) ? next() : authMiddleware.verifyExpressJWT(req, res, next);
    }
    else {
      next();
    }
  });
};

exports.applyLog = app => {
  app.use((req, res, next) => {
    logger.info(`request incoming from ${req.ip} - to ${package.name} - method: ${req.method} - hostname: ${req.hostname} - url: ${req.originalUrl}`)
    next();
  });
};