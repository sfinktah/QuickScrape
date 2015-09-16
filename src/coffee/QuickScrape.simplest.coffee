curl     =  require('request-promise')
Promise  =  require('bluebird')
html     =  require('cheerio')
_        =  require('lodash')

config =
  'url'      : 'http://www.judicialcollege.vic.edu.au/publications'
  'selector': '#primary-navigation > ul > li.expanded.active-trail a[href]'

class QuickScrape
  constructor: (url, @selector) ->
    @promise = curl(url)
      .then (page) =>
        ### Get a single web page, which has a list of publications 
        we are going to check
        ###
        @getStartingUrls page

      .then (urls) =>
        ### Launch a "thread" for each publication, which will crawl
        until it gets the direct URL for the publication, and filters
        undesirable ones.
        ###
        Promise.map urls, (url) =>
          curl(url)
            .then (page) =>
              @getFinalUrls page
        .call "filter", (href) ->
          href?.key?
          
        ### When all the URLs have been processed, it return to the
        outer promise
        ###
      .then (urls) ->
        console.log 'Inner and out loops complete, URLS: ' + JSON.stringify urls

    ###
    This will output before any work is actually done, since Promises
    are basically callbacks
    ###
    console.log 'The promise returned: ', @promise

  ###
  The rest of the code you can ignore, and is only there so the
  app still runs, proving it works :)
  ###
    
  getStartingUrls: (page) ->
    urls = []
    $ = html.load(page)
    console.log $(@selector).length + ' URLs found.'
    $(@selector).map (n, link) =>
      urls.push @getHref $(link)
      return
    urls

  getFinalUrls: (page) ->
      $ = html.load(page)
      href = @getHref2 $
      title= @getTitle $

      return unless href?

      if match = href.match /eManuals\/([A-Za-z_]+)\/index.htm/
        return (
          key: match[1]
          value: @getTitle($).trim()
        )
      console.log 'No match: ' + href

  getHref: ($) ->
    'http://www.judicialcollege.vic.edu.au' + $.attr('href')
  getHref2: ($) ->
    $('div.content > div.view-publication-link > a[href]').attr('href')
  getTitle: ($) ->
    $('div.content > div.publication-title').text()


qs = new QuickScrape config.url, config.selector


# vim: set ts=2 sts=2 sw=2 et:
