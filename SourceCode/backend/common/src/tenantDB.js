const MongoClient = require('mongodb').MongoClient;
const { logger } = require('./logger');
const helper = require('./helper');

let database = { mongoDBClient: null };
const collections = {
  users: 'users',
  tenants: 'tenants',
  roles: 'roles'
};

async function checkConnection() {
  try {
    if (!database.mongoDBClient) {
      await startMongoDB();
    }
    const adminDb = await database.mongoDBClient.db(process.env.MONGO_DB_NAME).admin();
    let status = await adminDb.serverStatus();
    return { connections: status.connections.current, ok: status.ok, version: status.version, uptime: status.uptime, localTime: status.localTime };
  } catch (err) {
    logger.error(err.message);
    return null;
  }
};

async function startMongoDB(tenantDatabaseName, tenantDatabaseUser, tenantDatabasePWS, retries = 0) {
  try {
    console.log(`mongodb - retries :>> `, retries);
    if (retries > 15) {
      console.log(`mongodb - max retries reached... exit now`);
      process.exit(1);
    }
    let mongodbconnection = `mongodb://${tenantDatabaseUser}:${tenantDatabasePWS}@${process.env.MONGO_DB_ADDRESS}:${process.env.MONGO_DB_PORT}/${tenantDatabaseName}/?authMechanism=${process.env.MONGO_DB_AUTHMECHANISM}&authSource=${process.env.MONGO_DB_AUTHSOURCE}&connectTimeoutMS=${process.env.MONGO_DB_CONNECTTIMEOUTMS}&maxPoolSize=${process.env.MONGO_DB_MAXPOOLSIZE}`;
    database.mongoDBClient = await MongoClient.connect(mongodbconnection, { useNewUrlParser: true });
  } catch (err) {
    logger.error(err.message);
    await helper.sleep(10000);
    retries = retries + 1;
    await startMongoDB(tenantDatabaseName, tenantDatabaseUser, tenantDatabasePWS, retries);
  }
};

module.exports = {
  startMongoDB,
  database,
  collections,
  checkConnection
};
