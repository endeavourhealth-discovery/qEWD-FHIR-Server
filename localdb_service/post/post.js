var uuid = require('uuid');
var version = require('../common/version.js');
var moment = require('moment');

module.exports = function (resource, query, body) {

  obj = JSON.parse(JSON.stringify(body));

  let docSubName = obj.data.body.resourceType;
  let documentName = "documents"

  if (docSubName == undefined) {
    var operationOutcome = {
      resourceType: "OperationOutcome",
      id: uuid.v4(),
      issue: [
        {
          code: "processing",
          severity: "fatal",
          diagnostics: 'Missing resourceType'
        }
      ]
    };
    var error = {
      error: "Bad Request",
      status: { code: 400 }
    }
    return {
      operationOutcome,
      error
    }
  }

  if (obj.data.body.id !== undefined && obj.data.body.id.length > 0) {
    var operationOutcome = {
      resourceType: "OperationOutcome",
      id: uuid.v4(),
      issue: [
        {
          code: "processing",
          severity: "fatal",
          diagnostics: docSubName + ' ' + obj.data.body.id + ' exists'
        }
      ]
    };
    var error = {
      error: "Bad Request",
      status: { code: 400 }
    }
    return {
      operationOutcome,
      error
    }
  }

  // ** CHECK REFERENCES!

  //Add an id property to the resource before persisting
  if (obj.data.body.id === undefined) {
    obj.data.body.id = uuid.v4();
  }

  mid = obj.data.body.id;

  z = JSON.stringify(body.data.body);
  for (i = 0; i < z.length; i += 1024) {
    var result = this.db.function({ function: 'A^UTILS', arguments: [mid, z.substr(i, 1024)] });
  }

  var temp = new this.documentStore.DocumentNode('temp', [process.pid]);
  temp.delete();

  var result = this.db.function({ function: 'CHECK^REFS', arguments: [mid] });
  var outputs = temp.getDocument();

  // check for mumps crashes
  if (outputs.error !== undefined) {
    var operationOutcome = {
      resourceType: "OperationOutcome",
      id: uuid.v4(),
      issue: [
        {
          code: "processing",
          severity: "fatal",
          diagnostics: docSubName + ' ' + outputs.error[1]
        }
      ]
    };
    var error = {
      error: "Bad Request",
      status: { code: 400 }
    }
    return {
      operationOutcome,
      error
    }
  }

  if (outputs.missing !== undefined) {
    z = outputs.missing[1];
    // implement operationOutcome here!
  }

  var doc = this.db.use(documentName, docSubName);

  var id = obj.data.body.id;
  doc.$(id).setDocument(obj.data.body);

  var result = this.db.function({ function: 'INDEX2^INDEX3', arguments: [id, docSubName] });

  return obj;
};
