// Generated by CoffeeScript 1.6.3
var Promise, QuickScrape, config, curl, html, qs, _;

curl = require('request-promise');

Promise = require('bluebird');

html = require('cheerio');

_ = require('lodash');

config = {
  'url': 'http://www.judicialcollege.vic.edu.au/publications',
  'selector': '#primary-navigation > ul > li.expanded.active-trail a[href]'
};

QuickScrape = (function() {
  function QuickScrape(url, selector) {
    var _this = this;
    this.selector = selector;
    this.promise = curl(url).then(function(page) {
      /* Get a single web page, which has a list of publications 
      we are going to check
      */

      return _this.getStartingUrls(page);
    }).then(function(urls) {
      /* Launch a "thread" for each publication, which will crawl
      until it gets the direct URL for the publication, and filters
      undesirable ones.
      */

      return Promise.map(urls, function(url) {
        return curl(url).then(function(page) {
          return _this.getFinalUrls(page);
        });
      }).call("filter", function(href) {
        return (href != null ? href.key : void 0) != null;
      });
      /* When all the URLs have been processed, it return to the
      outer promise
      */

    }).then(function(urls) {
      return console.log('Inner and out loops complete, URLS: ' + JSON.stringify(urls));
    });
    /*
    This will output before any work is actually done, since Promises
    are basically callbacks
    */

    console.log('The promise returned: ', this.promise);
  }

  /*
  The rest of the code you can ignore, and is only there so the
  app still runs, proving it works :)
  */


  QuickScrape.prototype.getStartingUrls = function(page) {
    var $, urls,
      _this = this;
    urls = [];
    $ = html.load(page);
    console.log($(this.selector).length + ' URLs found.');
    $(this.selector).map(function(n, link) {
      urls.push(_this.getHref($(link)));
    });
    return urls;
  };

  QuickScrape.prototype.getFinalUrls = function(page) {
    var $, href, match, title;
    $ = html.load(page);
    href = this.getHref2($);
    title = this.getTitle($);
    if (href == null) {
      return;
    }
    if (match = href.match(/eManuals\/([A-Za-z_]+)\/index.htm/)) {
      return {
        key: match[1],
        value: this.getTitle($).trim()
      };
    }
    return console.log('No match: ' + href);
  };

  QuickScrape.prototype.getHref = function($) {
    return 'http://www.judicialcollege.vic.edu.au' + $.attr('href');
  };

  QuickScrape.prototype.getHref2 = function($) {
    return $('div.content > div.view-publication-link > a[href]').attr('href');
  };

  QuickScrape.prototype.getTitle = function($) {
    return $('div.content > div.publication-title').text();
  };

  return QuickScrape;

})();

qs = new QuickScrape(config.url, config.selector);
