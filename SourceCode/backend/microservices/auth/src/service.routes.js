const { helper } = require('@1edge-backend/common-lib');
const { basicAthentication } = require('./services/user.service');
const package = require('../package.json');

exports.setRoutes = route => {
  route.get(`/v1/${package.name}/ping`, async (req, res) => helper.baseRequestHandler(req, res, () => ({ pong: true, service: package.name })));
  route.post(`/v1/${package.name}`, async (req, res) => helper.baseRequestHandler(req, res, basicAthentication));
}
