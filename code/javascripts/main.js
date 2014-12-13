"use strict"

function getParameterByName(name) {
  name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
  var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
      results = regex.exec(location.search);
  return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}

$.fn.redraw = function(){
  return $(this).each(function(){
    var redraw = this.offsetHeight;
  });
};

function initSearch() {
  var submitEvent = function(event) {
    var key = event.which;
    if(key == 13 /*<Enter>*/) {
      console.log("search key triggered");
      performSearch();
    }
  }
  $(".search-area").keypress(submitEvent)

  if (window['searchData'] == undefined)
    $.get("/document_index.json").success(function(data){

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
    '<div class="whole unit">' +
      '<div class="search-result">' +
        '<a class="result-title" href="/{{id}}.html">{{title}}</a>' +
        '<div class="grid">' +
          '<p class="result-desc half unit">{{{desc}}}</p>' +
          '<div class="half unit snippet-tags">' +
            '{{#each tags}}' +
              '<a class="snippet-tag" href="/?q=%5B{{this}}%5D">{{this}}</a>' +
            '{{/each}}' +
          '</div>' +
        '</div>' +
      '</div>' +
    '</div>' +
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
      $(".search-results-body")
        .append(searchResultTemplate(val));
    });

  setTimeout(function () {
    $(".search-results").css({
      height : $(".search-results-body").outerHeight(true),
    });
  }, 0)
}

if(window.searchPage){
  initSearch();
  if(getParameterByName("q")){
    var waitForLoad = function () {
      if(window['searchData'] == undefined){
        setTimeout(waitForLoad, 50)
      } else {
        $("#search-query").val(getParameterByName("q"));
        performSearch();
      }
    }
    waitForLoad();
  }
}
