getUrl   =  require('request-promise')
Promise  =  require('bluebird')
html     =  require('cheerio')
_        =  require('lodash')

config =
  'url'      : 'http://www.judicialcollege.vic.edu.au/publications'
  'container': '#primary-navigation > ul > li.expanded.active-trail a[href]'

class QuickScrape
  constructor: (url, container) ->
    @promise = getUrl(url)
      .then (response) =>
        urls = []
        $ = html.load(response)
        console.log $(container).length + ' URLs found'
        $(container).map (n, link) =>
          urls.push @getHref $(link)
          return
        console.log 'Pass #1. URLS: ' + urls.join ','
        return urls

      .then (urls) =>
        finalUrls = []

        Promise.map urls, (url) =>
          ### Inner Loop ###
          getUrl(url).then (response) =>
            $ = html.load(response)
            href = @getHref2 $
            title= @getTitle $

            return unless href?

            if match = href.match /eManuals\/([A-Za-z_]+)\/index.htm/
              finalUrls.push match[1]
              return (
                key: match[1]
                value: @getTitle($).trim()
              )
            console.log 'No match: ' + href

        .call "filter", (href) ->
          href?.key?
          
      .then (urls) ->
        console.log 'Inner and out loops complete, URLS: ' + JSON.stringify urls

    console.log 'The promise returned: ', @promise

  getHref: ($) ->
    'http://www.judicialcollege.vic.edu.au' + $.attr('href')
  getHref2: ($) ->
    $('div.content > div.view-publication-link > a[href]').attr('href')
  getTitle: ($) ->
    $('div.content > div.publication-title').text()


qs = new QuickScrape config.url, config.container


# vim: set ts=2 sts=2 sw=2 et:
