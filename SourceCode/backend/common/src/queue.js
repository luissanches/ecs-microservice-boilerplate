const amqp = require('amqplib/callback_api');
const { logger } = require('./logger');
const envs = process.env

let queueConnection = null
let queueChannel = null

exports.getConnection = () => {
  return new Promise((resolve, reject) => {
    amqp.connect(`amqp://${envs.RABBITMQ_USER}:${envs.RABBITMQ_PASSWORD}@${envs.RABBITMQ_ADDRESS}:${envs.RABBITMQ_PORT}`, function (error0, connection) {

      if (error0) {
        reject(error0)
      } else {
        resolve(connection)
      }
    })
  });
}

exports.getChannel = (connection) => {
  return new Promise((resolve, reject) => {
    connection.createChannel(function (error1, channel) {
      if (error1) {
        reject(error1)
      } else {
        resolve(channel)
      }
    })
  });
}

// ########## Publish message in queue 
exports.postMessage = async (msg, queueName) => {
  try {
    if (!queueConnection) {
      queueConnection = await this.getConnection()
    }
    if (!queueChannel) {
      queueChannel = await this.getChannel(queueConnection)
    }

    queueChannel.assertQueue(queueName, { durable: false });
    queueChannel.sendToQueue(queueName, Buffer.from(msg));

  } catch (err) {
    logger.error(err.message)
  }
}

// ########## Publish message in exchange
exports.postFanoutMessage = async (message, queueName) => {
  try {
    if (!queueConnection) {
      queueConnection = await this.getConnection()
    }
    if (!queueChannel) {
      queueChannel = await this.getChannel(queueConnection)
    }

    let msg = JSON.stringify(message);

    queueChannel.assertExchange(queueName, 'fanout', { durable: false });
    queueChannel.publish(queueName, '', Buffer.from(msg));

  } catch (err) {
    logger.error(err.message)
  }
}

