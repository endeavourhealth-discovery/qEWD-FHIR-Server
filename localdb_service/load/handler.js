var fs = require('fs');
var traverse = require('traverse');

function isInt(value) {
  return !isNaN(value) && parseInt(Number(value)) == value && !isNaN(parseInt(value, 10));
}

function SaveInDB(db, documentName, docSubName, body)
{
  var doc = db.use(documentName, docSubName);
  var id = doc.increment();
  doc.$(id).setDocument(body);
  // create indices
  var docIndex = db.use(documentName + 'Index', docSubName);

  console.log(docSubName);

  traverse(body).map(function(node) {
    if (typeof node !== 'object' && node !== '') {
      var subscripts = [];
      this.path.forEach(function(sub) {
        if (!isInt(sub)) subscripts.push(sub);
      });
      subscripts.push(node);
      subscripts.push(id);
      docIndex.$(subscripts).value = id;
    }
  });
  return true;
}

module.exports = function(args, finished) {
  var dir = args.req.body.dir;
  console.log(dir);

  var db = this.db;

  fs.readdir(dir, function (err, files) {
    if (err)
      throw err;
    for (var index in files) {
      console.log(files[index]);

      var stats = fs.statSync(dir + '/' + files[index]);

      if (stats.isDirectory()) {
        continue;
      }
      var json = fs.readFileSync(dir+'/'+files[index], 'utf8');
      jobj = JSON.parse(json);

      var st = SaveInDB(db, 'Schemas', files[index], jobj);
    }
  });
  
  finished({ok: true});
};