var search = require('./search');

module.exports = function(args, finished) {
  finished(search.call(this, args.resource, args.req.query, args.req.body));
};