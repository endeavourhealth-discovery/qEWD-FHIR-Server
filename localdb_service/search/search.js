var uuid = require('uuid');
var moment = require('moment');

module.exports = function(resource, query, body) {

  let docSubName = body.data.resourceType;

  var temp = new this.documentStore.DocumentNode('temp', [process.pid]);
  temp.delete();
  
  var result = this.db.function({function: 'SEARCH^SRCH3', arguments: [JSON.stringify(body), docSubName]});

  var results = [];

  var outputs = temp.getDocument();
  var z = outputs.howmany + 1;

  //Return bundle
  // *** TO DO: if _include add search mode
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

  if (outputs.first !== undefined) {
    var pages = [];
    pages[0] = outputs.self;
    pages[1] = outputs.first;
    pages[2] = outputs.previous;
    pages[3] = outputs.next;
    pages[4] = outputs.last;

    var relation = [];
    relation[0] = 'self';
    relation[1] = 'first';
    relation[2] = 'previous';
    relation[3] = 'next';
    relation[4] = 'last';

    var i;
    for (i = 0; i < pages.length; i++) {
      var f = {
        relation: relation[i],
        url: pages[i]
      };
      bundle.link.push(f);
    }
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

  return bundle;  
};
