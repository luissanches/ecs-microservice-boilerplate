console.log('started....');
const fastify = require('fastify')();

fastify.get('/', async (request, reply) => {
  return { hello: 'world' }
})

const start = async () => {
  try {
    await fastify.listen(3001, '0.0.0.0')
    console.log('listening....');
  } catch (err) {
    console.log(`err ${err.message}`);
    fastify.log.error(err)
    process.exit(1)
  }
}

start()