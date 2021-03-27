const { database, collections } = require('./coreDB');
const envs = process.env;

exports.getActiveOnlineStations = async ({ coordinates, userId, searchDistance }, removeUser = false) => {
  let query = { userIsOnline: true, activated: true }
  if (removeUser) query.userId = { $ne: userId }

  let docs = await database.mongoDBClient.db(envs.MONGO_DB_NAME).collection(collections.stations).aggregate([
    {
      $geoNear: {
        near: { type: "Point", coordinates },
        distanceField: "distance",
        maxDistance: searchDistance || Number(envs.STATIONS_SEARCH_DISTANCE),
        query,
        spherical: true
      }
    }
  ]).toArray()
  return docs
}