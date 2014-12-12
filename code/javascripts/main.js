$.get("http://localhost:8888/search_index.json").success(function(data){
  console.log("got search index");
  window.searchIndex = data;
}).fail(function(failcode){
  console.log("failed to get index: ");
  console.log(failcode);
});

function tokenizeSearchQuery(query) {
  var seperators = / |\.|\n|\r|\t|\(|\)|\{|\}|\[|\]|:|;|!|\?/;
  var result = query.split(seperators);
  result = _.filter(result, function(val){ return val.length != 0; });
  return result;
}

function getRelevences(terms) {
  var selectedWeights = _.pick.apply(null, [window.searchIndex].concat(terms));
  return _.reduce(selectedWeights, function(accm, curr){
    _.each(curr, function(val){
      if(val.doc in accm)
        accm[val.doc] += val.rel;
      else
        accm[val.doc] = val.rel;
    });

    return accm;
  }, {});
}
