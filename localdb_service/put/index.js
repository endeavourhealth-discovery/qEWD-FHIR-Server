var put = require('./put');

module.exports = function(args, finished) {
  finished(put.call(this, args.resource, args.req.query, args.req.body));
};