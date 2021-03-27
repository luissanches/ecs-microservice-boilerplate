const { helper } = require('@1edge-backend/common-lib');
const { basicAthentication } = require('./services/user.service');

module.exports = {
  basicAuth: {
    method: 'POST', url: '/v1/auth',
    schema: {},
    handler: async (request, reply) => {
      try {
        let auth = await basicAthentication(request.body);
        reply.send(helper.makeDefaultResponse(auth));
      } catch (err) {
        reply.send(helper.makeDefaulErrortResponse(err.message));
      }
    }
  },
  ping: {
    method: 'GET', url: '/v1/auth/ping',
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