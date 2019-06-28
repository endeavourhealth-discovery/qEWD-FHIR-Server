module.exports = function(args, finished) {

  let global = args.req.query.global;
  let str = args.req.query.str;

  var temp = new this.documentStore.DocumentNode('temp', [process.pid]);
  temp.delete();

  var result = this.db.function({ function: 'FIND^GFIND', arguments: [global, str] });
  var outputs = temp.getDocument();

  finished(outputs);
}