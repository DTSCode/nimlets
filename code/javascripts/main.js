"use strict"

function initSearch() {
  var submitEvent = function(event) {
    var key = event.which;
    if(key == 13 /*<Enter>*/) {
      console.log("search key triggered");
      performSearch();
    }
  }
  $("div #search-area").keypress(submitEvent)

  if (window['searchIndex'] == undefined ||
      window['idToName'] == undefined)
    $.get("http://localhost:8888/search_index.json").success(function(data){
      console.log("got search index");
      window.searchIndex = data["index"];
      window.idToName = data["idToName"];
    }).fail(function(failcode){
      console.log("failed to get index: ");
      console.log(failcode);
    });
}

function tokenizeSearchQuery(query) {
  var seperators = / |\.|\n|\r|\t|\(|\)|\{|\}|:|;|!|\?/;
  var result = query.split(seperators);
  result = _.filter(result, function(val){ return val.length != 0; });
  return result;
}

function getRelevences(terms) {
  var selectedWeights = _.pick.apply(null, [window.searchIndex].concat(terms));

  var result = _.reduce(selectedWeights, function(accm, curr){
    _.each(curr, function(val){
      if(val.doc in accm)
        accm[val.doc] += val.rel;
      else
        accm[val.doc] = val.rel;
    });

    return accm;
  }, {});

  result = _(result).chain()
    .pairs()
    .map(function (v) { return [v[1], v[0]] })
    .sortBy(function (v) { return v[0] })
    .first(50)
    .map(function (v) { return v[1] })
    .value();

  return result
}

function performSearch() {
  var query = $("#search-query").val();
  var queryTokens = tokenizeSearchQuery(query)

  var results = getRelevences(queryTokens)

  var resultBody = $(".search-results-body")
  resultBody.empty();

  _(results).each(function (val) {
    var template = Handlebars.compile(
      '<div class="grid search-result">' +
      '  <div class="unit whole">' +
      '    <a href="{{{ url }}}">{{ name }}</a>' +
      '  </div>' +
      '</div>')

    resultBody.append(template({
      url : "/" + val + ".html",
      name : window.idToName[val],
    }))
  })

  $('.search-results').show();
}

if(window.searchPage)
  initSearch()
