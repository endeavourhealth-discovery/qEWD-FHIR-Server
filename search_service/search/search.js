// Construct search specification (populate a language neutral representation of the search)
// Manage cursor (if involving :count directive)
// Dispatch requests (this is where the references are checked using data adaptors -> resource identifier globals)
// + translates business identifires into resource identifiers
// Sort results (if request contains _sort)

module.exports = function(resource, query, body) {
  
  let str = JSON.stringify(body.data.query);

  let q = str.replace(/{/g, '');
  q = q.replace(/}/g, '');
  
  resource = JSON.stringify(body.data.resource);
  
  if (q == '') {
    q='"all":"*"'
  }

  let jsonstr = '{"resourceType": ' + resource + ',' + q + ',"thequery": ' + str + '}';

  return JSON.parse(jsonstr); 
};
