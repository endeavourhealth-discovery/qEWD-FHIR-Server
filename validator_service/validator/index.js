var validator = require('./validator');
var uuid = require('uuid');

module.exports = function (args, finished) {

  var methods = ["POST", "PUT", "PATCH"];
  var n = methods.includes(args.req.method);

  zarray = args.req.path;
  zarray = zarray.split("/");
  docSubName = zarray[3];
  console.log(docSubName);

  if (n == true) {

    resourcetype = args.req.body.resourceType;

    diagnostics = '';
    var supported = ["Patient", "Practitioner", "Encounter", "Organization", "Subscription", "Observation", "Medication","MedicationStatement"];

    // resourcetype supported?
    /*
    var n = supported.includes(resourcetype, 0);
    if (n == false) {
      diagnostics = resourcetype + ' resourceType in body not supported';
    }
    */

    // docSubName supported?
    /*
    var n = supported.includes(docSubName, 0);
    if (n == false) {
      diagnostics = docSubName + ' in query string not supported';
    }
    */
   
    if (resourcetype !== docSubName) {
      diagnostics = 'Query details different to resource in payload [' + resourcetype + '] [' + docSubName + ']';
    }

    if (diagnostics !== '') {

      var error = {
        error: 'Not Found',
        status: { code: 404 }
      }

      var apiMessage = {};

      console.log(diagnostics);
      apiMessage.operationOutcome = {
        resourceType: 'OperationOutcome',
        id: uuid.v4(),
        issue: [
          {
            code: 'processing',
            severity: 'fatal',
            diagnostics: diagnostics
          }
        ]
      };

      apiMessage.error = error;

      finished({
        apiMessage,
        error
      });
    }
  }

  finished(validator.call(this, args.resource, args.req.query, args.req.body, args.req.method, args.req.path, args.id));
};