const { coreDB, helper, logger, envs, constants } = require('@1edge-backend/common-lib');
const { newGuid, getHash, hashCompare } = helper;

exports.upsertUser = async ({ body }) => {
  try {
    let { user } = body;
    let userFound = await coreDB.database.mongoDBClient.db(envs.MONGO_DB_NAME).collection(coreDB.collections.users).find({ 'login': user.login }).toArray();
    if (userFound.length > 0) {
      return { error: constants.ERROR_MESSAGE.USER_ALREADY_EXISTS };
    }
    else {
      user.userId = newGuid();
      user.password = getHash(user.password);
      user.activated = true;
      user.createdAt = new Date();
      await coreDB.database.mongoDBClient.db(envs.MONGO_DB_NAME).collection(coreDB.collections.users).insertOne(user);
      delete user['password'];
      user.token = (helper.jwt.generateJWT(user));
      return user; 
    }
  } catch (err) {
    logger.error(err.message);
    throw Error('upsert user error');
  }
};

exports.basicAthentication = async ({ body }) => {
  let { login, password } = body;
  try {
    let [user] = await database.mongoDBClient.db(envs.MONGO_DB_NAME).collection(collections.users).find({ login }).toArray();
    if (!user || !user.activated) return null;
    user.authenticated = hashCompare(password, user.password);
    if (user.authenticated) {
      delete user['password'];
      user.token = helper.jwt.generateJWT(user);
    }
    return user;
  } catch (err) {
    logger.error(err.message)
    throw new Error('auth user error');
  }
};
