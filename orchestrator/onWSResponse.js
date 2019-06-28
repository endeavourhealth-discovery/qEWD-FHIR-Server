var util = require('util');

var responseHandlers = {
    get: function(resource, res)
        {
            res.set('Content-Length', resource.length);
            res.status(200);
            
            if (resource.apiMessage !== undefined) {
	            delete resource.apiMessage.searchservice.token;
                res.send(resource.apiMessage.searchservice);
            }
            else {
                res.send(resource);
            }
        },
    post: function(resource, res)
        {
            res.status(201);
            res.set('Content-Length', resource.length);

            if (resource.apiMessage !== undefined) {
	            obj = resource.apiMessage.data;
                body = obj.body;

                res.set('Location','http://localhost:8080/fhir/STU3/'+body.resourceType+'/'+body.id);
            }
            //Etag should be version
            res.send('');
        },
    put: function(resource, res)
        {
            res.status(204);
            res.send();
        },
    delete: function(resource, res)
        {
            res.status(202);//Non commital (lol)
            res.send();
        }
}

module.exports = function(req, res, next) {

    var msg = res.locals.message || {error: "Internal server error"};
    var code, status;

    var objerror;

    if (msg.apiMessage !== undefined) {
        if (msg.apiMessage.operationOutcome != undefined) {
            objiss = msg.apiMessage.operationOutcome.issue;
            objerror = msg.apiMessage.error.error;
            objstatus = msg.apiMessage.error.status;
        }
    }
   
    if (objerror) {
        code = 500;
        status = msg.apiMessage.error.status;
        if(status && status.code) code = status.code;

        if(msg.apiMessage.operationOutcome !== undefined)
        {
            msg = msg.apiMessage.operationOutcome;
        } 
        else 
        {
            delete msg.apiMessage.error.status;
            delete msg.apiMessage.restMessage;
            delete msg.apiMessage.ewd_application;
        }

        res.set('Content-Length', msg.length);
        res.status(code).send(msg);
    } else {
        var resource = msg;

	if (resource.token !== undefined) delete resource.token;

        //Send Response...
        var responseHandler = responseHandlers[req.method.toLowerCase()];
        responseHandler(resource,res);
    }
    next();
  };