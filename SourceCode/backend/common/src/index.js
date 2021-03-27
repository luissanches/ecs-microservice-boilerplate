require('./load_envs').load()
const { logger } = require('./logger')
const coreDB = require('./coreDB')
const tenantDB = require('./tenantDB')
const authMiddleware = require('./authMiddleware')
const queue = require('./queue')
const helper = require('./helper')
const constants = require('./constants')
const queries = require('./queries')


module.exports = {
  coreDB,
  tenantDB,
  helper,
  authMiddleware,
  queue,
  logger,
  envs: process.env,
  constants,
  queries
}