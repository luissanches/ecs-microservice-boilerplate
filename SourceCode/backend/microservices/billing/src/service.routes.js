const { helper } = require('@1edge-backend/common-lib');
const { ping } = require('./services/example.service');
const package = require('../package.json');
const os = require("os");

exports.setRoutes = route => {
  route.get(`/v1/${package.name}/ping`, async (req, res) => helper.baseRequestHandler(req, res, () => {
    let nets = os.networkInterfaces();
    let ips = {};
    let version = package.version;

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
    return { pong: true, version, service: package.name, hostname, ips };
  }));
  route.get(`/v1/${package.name}/ping2`, async (req, res) => helper.baseRequestHandler(req, res, ping));
}