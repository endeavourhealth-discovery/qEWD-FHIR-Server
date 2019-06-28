var uuid = require('uuid');

module.exports = function(args, finished) {
    
    var resourceType = args.resource || '';
    var resourceId = args.id || '';

    try
    {    
        var resource = this.db.use('documents', resourceType, resourceId);

        var error = {
          error: 'Not Found',
          status: { code: 404 }
        }

        var apiMessage = {}

        if(!resource.exists) {
            apiMessage.operationOutcome = {
                resourceType: 'OperationOutcome',
                id: uuid.v4(),
                issue: [
                  {
                    code: 'processing',
                    severity: 'fatal',
                    diagnostics: 'Resource ' + resourceType + ' ' + resourceId + ' does not exist'
                  }
                ]
              };

	            apiMessage.error = error;

              finished({
                apiMessage,
                error
              });
        } else {
          resource = resource.getDocument(true);

          // LOL!
          if (resourceType == 'Patient' && resource.identifier !== undefined) {
            x = resource.identifier[0].value;
            x = x.toString();
            console.log(x);
            resource.identifier[0].value = x;
          }
          console.dir(resource);

          finished(resource);
        }
    } catch(ex) {
        finished({
            error: ex.stack || ex.toString(),
            status:{code:500}
        });
    } 
}