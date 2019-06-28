module.exports = function(message, jwt, forward, sendBack) {

  // Validate JWT
  // Read and Validate Resource Payload
  // Validate JSON Patch Document
  // Decompose URL
  // Validate request against Capability statement

  if (message.method == 'GET') {
  	var apiRequest = {
    		path: '/fhirsearch',
    		method: 'POST',
    		body: {breakchain:"false",data:message}
  	};
  }

  if (message.method == 'POST') {
  	var apiRequest = {
    		path: '/fhirpost',
    		method: 'POST',
    		body: {breakchain:"false",data:message}
    };
  }

  if (message.method == 'PUT') {
    var apiRequest = {
        path: '/fhirput',
        method: 'PUT',
        body: {breakchain:"false",data:message}
    };
  }
  
forward(apiRequest, jwt, function(responseObj) {
      var apiMessage = responseObj.message;

      let method = apiMessage.method;

      if (method == 'post') {
        responseObj.message = {
          apiMessage
        }
      }
      
      if (method !== 'post') {
        responseObj.message = {
	      apiMessage
        }
      }

      sendBack(responseObj);
  });
};