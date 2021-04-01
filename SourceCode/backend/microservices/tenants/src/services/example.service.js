const { logger, envs, helper, coreDB } = require('@1edge-backend/common-lib');
const package = require('../../package.json');

exports.ping = async({ body, params, query }) => {
  logger.debug(body)
  return { pong: true, service: package.name };
}
