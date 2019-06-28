var post = require('./post');

module.exports = function(args, finished) {
  finished(post.call(this, args.resource, args.req.query, args.req.body));
};