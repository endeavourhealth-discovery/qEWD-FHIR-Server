var traverse = require('traverse');

module.exports = function(message, jwt, forward, sendBack) {

  var apiRequest = {
    path: '/localdbsearch',
    method: 'GET',
    body: {breakchain:"false",data:message}
};
  
forward(apiRequest, jwt, function(responseObj) {

   var apiMessage = responseObj.message

   responseObj.message = {
     searchservice: apiMessage
   }

   sendBack(responseObj);

  });
};