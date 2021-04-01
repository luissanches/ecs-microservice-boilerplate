const { helper } = require('@1edge-backend/common-lib');
const { ping } = require('./services/example.service');
const package = require('../package.json');

exports.setRoutes = route => {
  route.get(`/v1/${package.name}/ping`, async (req, res) => helper.baseRequestHandler(req, res, () => ({ pong: true, service: package.name })));
  route.get(`/v1/${package.name}/ping2`, async (req, res) => helper.baseRequestHandler(req, res, ping));
}