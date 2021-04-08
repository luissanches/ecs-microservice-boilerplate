const { helper } = require('@1edge-backend/common-lib');
const { basicAthentication } = require('./services/user.service');
const package = require('../package.json');
const os = require("os");


exports.setRoutes = route => {
  route.get('/', async (req, res) => helper.baseRequestHandler(req, res, () => ({ ok: true })));
  route.get(`/v1/${package.name}/ping`, async (req, res) => helper.baseRequestHandler(req, res, () => {
    let nets = os.networkInterfaces();
    let ips = {};

    for (const name of Object.keys(nets)) {
      for (const net of nets[name]) {
        if (net.family === 'IPv4' && !net.internal) {
          if (!ips[name]) {
            ips[name] = [];
          }
          ips[name].push(net.address);
        }
      }
    }
    let hostname = os.hostname();
    return { pong: true, service: package.name, hostname, ips };
  }));
  route.post(`/v1/${package.name}`, async (req, res) => helper.baseRequestHandler(req, res, basicAthentication));
}
