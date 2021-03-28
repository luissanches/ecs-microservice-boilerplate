const { helper } = require('@1edge-backend/common-lib');
const { basicAthentication } = require('./services/user.service');

module.exports = {
  ping: {
    method: 'GET', url: '/v1/tenants/ping',
    schema: {},
    handler: async (request, reply) => {
      try {
        reply.send(helper.makeDefaultResponse({ pong: true }));
      } catch (err) {
        reply.send(helper.makeDefaulErrortResponse(err.message));
      }
    }
  }
};