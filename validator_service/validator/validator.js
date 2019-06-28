module.exports = function(resource, query, body, method, path, idee) {
  // *** TO DO validation
  // Validate JWT
  // Read and Validate Resource Payload
  // 
  return {
    query: query,
    resource: resource,
    body: body,
    method: method,
    pathdets: path,
    idee: idee,
    ok: true
  };
};
