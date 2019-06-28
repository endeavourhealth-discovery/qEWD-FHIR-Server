var uuid = require('uuid');

module.exports = function(resource, query, body) {

  obj=JSON.parse(JSON.stringify(body));

  // resource id
  let idee = obj.data.idee;
  let docSubName = obj.data.body.resourceType;

  // does resource exist in the db?
  var resource = this.db.use('documents', docSubName, idee);

  if(!resource.exists) {
    var operationOutcome = {
      resourceType: "OperationOutcome",
      id: uuid.v4(),
      issue: [
        {
          code:"processing",
          severity:"fatal",
          diagnostics:docSubName + ' ' + idee + ' does not exist'
        }
      ]
    };
    var error = {
      error:"Bad Request",
      status: {code:400}
    }
    return {
      operationOutcome,
      error
    }
  }

  var temp = new this.documentStore.DocumentNode('temp', [process.pid]);
  temp.delete();

  var result = this.db.function({function: 'KILL^KILL3', arguments: [docSubName, idee]});
  
  obj.data.body.id = idee;

  var doc = this.db.use('documents', docSubName);
  doc.$(idee).setDocument(obj.data.body);

  var result = this.db.function({function: 'INDEX2^INDEX3', arguments: [idee, docSubName]});

  return obj;
};