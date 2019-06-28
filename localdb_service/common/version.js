module.exports = function(documentName, docSubName, resource)
{
      //Create version...
      var versions = this.db.use(documentName + 'ver', docSubName);
      versions.$(resource.id + '_' + resource.meta.versionId).setDocument(resource);

      return {status:"OK"};
}