const path = require('path');

module.exports.load = () => {
	if (process.env.NODE_ENV === 'development' || process.env.NODE_ENV === 'debug' || process.env.NODE_ENV == undefined)
		require('dotenv').config({ path: path.resolve(__dirname, '.env') });
};