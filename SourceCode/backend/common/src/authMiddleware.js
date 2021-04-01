const {jwt} = require('./helper');

exports.verifyJWT = async (request, reply, done) => {
	const header = request.headers;
	if(header.authorization != null){
		const token = header.authorization.replace('Bearer ','');
		try{
			const decoded = await jwt.validateJWT(token);
			request.user = decoded;
			done();
		}
		catch (exception){
			reply.code(401).send('Invalid token');
		}
	}
	else{
		reply.code(401).send('Access denied. No token provided');
	}    
}; 

exports.verifyExpressJWT = async (req, res, next) => {
	const header = req.headers;
	if(header.authorization != null){
		const token = header.authorization.replace('Bearer ','');
		try{
			const decoded = await jwt.validateJWT(token);
			req.user = decoded;
			next();
		}
		catch (exception){
			res.status(401).send('Invalid token');
		}
	}
	else{
		res.status(401).send('Access denied. No token provided');
	}    
}; 