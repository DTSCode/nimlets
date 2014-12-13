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

  if (window['searchData'] == undefined)
    $.get("http://localhost:8888/document_index.json").success(function(data){

      console.log("got search index");
      window.searchData = new Fuse(data, {
        keys: ['author', 'title', 'code', 'desc'],
      });

    }).fail(function(failcode){
      console.log("failed to get index: ");
      console.log(failcode);
    });
}

function processQuery(query) {
  /* Returns ["query without tags", ["list", "of", "tags"]]
   *
   * A tag looks like `[foo-bar]`
   */
  var tags = []
  var re = /\[\s*([^\]\[\s]+)\s*\]/g;
  var m;

  while ((m = re.exec(query)) != null) {
    if (m.index === re.lastIndex) re.lastIndex++;
    tags.push(m[1]);
  }

  var newQuery = query
    .replace(re, "")
    .replace(/\s{2,}/, " ");

  return [newQuery, tags];
}

var searchResultTemplate = Handlebars.compile(
  '<div class="grid">' +
    '<a class="search-result whole" href="/{{id}}.html">' +
      '<h3>{{title}}</h3>' +
      '<div class="grid">' +
        '<h4 class="half unit">{{author}}</h4>' +
        '<div class="half unit snippet-tags">' +
          '{{#each tags}}' +
            '<a class="snippet-tag" href="/tags#t={{this}}">{{this}}</a>' +
          '{{/each}}' +
        '</div>' +
      '</div>' +
    '</a>' +
  '</div>')

function performSearch() {
  var query = $("#search-query").val();
  query = processQuery(query)

  $(".search-results-body").empty();

  var searchResults = window.searchData.search(query[0]);
  if(_(searchResults).isEmpty())
    searchResults = window.searchData.list

  _(searchResults)
    .chain()
    .filter(function (val) {
      var tags = query[1];
      return _(tags).isEmpty() || _(tags).reduce(function (accm, curr) {
        return accm && _(val.tags).contains(curr);
      }, true)
    })
    .each(function (val) {
      $(".search-results").show();
      $(".search-results-body")
        .append(searchResultTemplate(val));
    });
}

if(window.searchPage)
  initSearch()
