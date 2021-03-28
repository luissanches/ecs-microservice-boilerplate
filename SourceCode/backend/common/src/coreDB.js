const MongoClient = require('mongodb').MongoClient;
const { logger } = require('./logger');
const helper = require('./helper');

//{ useUnifiedTopology: true }

const mongodbconnection = `mongodb://${process.env.MONGO_DB_USER}:${process.env.MONGO_DB_PWS}@${process.env.MONGO_DB_ADDRESS}:${process.env.MONGO_DB_PORT}/${process.env.MONGO_DB_NAME}/?authMechanism=${process.env.MONGO_DB_AUTHMECHANISM}&authSource=${process.env.MONGO_DB_AUTHSOURCE}&connectTimeoutMS=${process.env.MONGO_DB_CONNECTTIMEOUTMS}&maxPoolSize=${process.env.MONGO_DB_MAXPOOLSIZE}&useUnifiedTopology=true`;

let database = { mongoDBClient: null };
const collections = { 
  users: 'users', 
  tenants: 'tenants',
  roles: 'roles'
};

async function startMongoDB(retries = 0) {
  try {
    console.log(`mongodb - retries :>> `, retries);
    if (retries > process.env.MONGO_DB_CONNECTION_RETRIES) {
      console.log(`mongodb - max retries reached... exit now`);
      process.exit(1);
    }
    database.mongoDBClient = await MongoClient.connect(mongodbconnection, { useNewUrlParser: true });
  } catch (err) {
    logger.error(err.message);
    await helper.sleep(process.env.MONGO_DB_SLEEP_CONNECTION_RETRY);
    retries = retries + 1;
    await startMongoDB(retries);
  }
};

async function checkConnection () {
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

startMongoDB();

module.exports = {
  database,
  collections,
  checkConnection
};
