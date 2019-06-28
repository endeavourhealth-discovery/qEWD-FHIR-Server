module.exports = function(args, finished) {
  
  let zresource = args.resource;
  let zid = args.id

  var temp = new this.documentStore.DocumentNode('temp', [process.pid]);
  temp.delete();

  var result = this.db.function({ function: 'KILL^GFIND', arguments: [zresource, zid] });
  var outputs = temp.getDocument();

  finished(outputs);
}