const { v4: uuidv4 } = require('uuid');
const base64 = require('js-base64').Base64;
const randomstring = require('randomstring');
const _ = require('lodash');
const moment = require('moment-timezone');
const bcryptjs = require('bcryptjs');
const jwt = require('jsonwebtoken');
const currencyFormatter = require('currency-formatter');
const AWS = require('aws-sdk');

moment.locale(process.env.LOCALE);
moment.tz.setDefault(process.env.TIME_ZONE);

AWS.config.update({
	region: process.env.AWS_REGION,
	accessKeyId: process.env.AWS_KEY,
	secretAccessKey: process.env.AWS_SECRET
});
exports.AWS = AWS;

exports.makeDefaultResponse = (payload, msg) => {
  let defaultMessage = { payload, status: 'success', msg };
  return defaultMessage;
};
exports.makeDefaulErrortResponse = (msg) => {
  let defaultMessage = { status: 'error', msg };
  return defaultMessage;
};
exports.baseRequestHandler = async (req, res, service) => {
  try {
    if (!service) throw Error('No service to handling');
    let response = await service(req);
    res.send(this.makeDefaultResponse(response));
  } catch (err) {
    res.send(this.makeDefaulErrortResponse(err.message));
  }
}

exports.generateRandomString = (size = 5, prefix = null, charset = null) => {
  let options = { length: size };
  if (charset)
    options.charset = charset;
  return prefix ? `${prefix}-${randomstring.generate(options)}` : randomstring.generate(options);
};

exports.newGuid = () => {
  return uuidv4();
};
exports.getHash = (value) => {
  return bcryptjs.hashSync(value, parseInt(process.env.CRYPT_SALT));
};

exports.hashCompare = (plainValue, hashValue) => {
  return bcryptjs.compareSync(plainValue, hashValue);
};

exports.jwt = {
  generateJWT(data) {
    return jwt.sign({ data }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES });
  },
  validateJWT(token) {
    return jwt.verify(token, process.env.JWT_SECRET);
  }
}

exports.base64 = {
  encode(value) {
    return base64.encode(value);
  },
  decode(value) {
    return base64.decode(value);
  }
};

exports.sleep = async (mileseconds) => {
  return new Promise((resolve) => {
    setTimeout(resolve, mileseconds);
  });
};

exports.deepClone = (value) => {
  return _.cloneDeep(value);
};

exports.datetime = {
  toDateTime(stringDateTime, sourceFormat = 'YYYYMMDDHHmm', responseFormat = 'YYYYMMDD') {
    return moment(stringDateTime, sourceFormat).format(responseFormat);
  },
  toDBDate(date, format = 'YYYYMMDD') {
    return moment(date, format).toDate();
  },
  getMomment() {
    return moment();
  },
  rawMoment: moment
};

exports.currency = {
  numberToCurrencyDisplay(number) {
    return currencyFormatter.format(number, {
      symbol: '$ ',
      decimal: '.',
      thousand: ',',
      precision: 2
    });
  }
};