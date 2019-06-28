var uuid = require('uuid');
var moment = require('moment');

module.exports = function(args, finished) {
  console.log('everything');
  
  var resourceId = args.id || '';
  
  var temp = new this.documentStore.DocumentNode('temp', [process.pid]);
  temp.delete();

  var result = this.db.function({ function: 'FINDREV^EVERYTHING', arguments: [resourceId] });
  var outputs = temp.getDocument();
  
  //outputs = JSON.parse('{"everyting":{"bob": 1}}');
  
  var z = outputs.howmany + 1;
  
  var bundle = {
    resourceType:"Bundle",
    id: uuid.v4(),
    meta:{
      lastUpdated: moment().utc().format()
    },
    type:"searchset",
    total:0,
    link:[],
    entry:[]
  }
  
  if (z>0) {
    for (i=1; i < z; i ++) {
      x = outputs.Ids[i];

      zarray = x.split("|"); // include stuff
      id = zarray[0];
      docSubName = zarray[1];

      zmode = 'match';
      if (zarray[2] == 'INC') { zmode='include';}

      doc = this.db.use('documents', docSubName);

      var resource = doc.$(id).getDocument(true);

      // LOL!
      if (docSubName == 'Patient' && resource.identifier !== undefined) {
        x = resource.identifier[0].value;
        x = x.toString();
        console.log(x);
        resource.identifier[0].value = x;
      }

      var entry = {
        fullUrl:'http://localhost:8080/fhir/STU3/' + docSubName + '/'+ id,
        search: {
          mode: zmode
        },
        resource: resource
      };
      bundle.entry.push(entry); 
      if (zmode=='match') { bundle.total += 1; }
    }
  }
  
  if (outputs.bundletot !== undefined)
  {
    bundle.total = outputs.bundletot;
  }
  
  finished(bundle);
}