rp = require('request-promise')
Promise = require("bluebird")
cheerio = require('cheerio')
_ = require('lodash')

config =
  'domain'   : 'http://www.judicialcollege.vic.edu.au'
  'url'      : 'http://www.judicialcollege.vic.edu.au/publications'
  'container': '#primary-navigation > ul > li.expanded.active-trail a[href]'

class QuickScrape
  constructor: (@config = {}) ->
    @jsPromise = rp(config.url)
      .then (response) ->
        $ = cheerio.load(response)
        pubUrls = []
        $(config.container).map (i, link) ->
          href = config.domain + $(link).attr('href') 
          pubUrls.push href
          return
        pubUrls
      .then (pubUrls) ->
        finalUrls = []
        Promise.map pubUrls, (pubUrl) ->
          rp(pubUrl).then (response) ->
            $ = cheerio.load(response)
            href = $('div.content > div.view-publication-link > a[href]').attr('href')
            title= $('div.content > div.publication-title').text()
            return unless href?
            if match = href.match /eManuals\/([A-Za-z_]+)\/index.htm/
              console.log 'match', match[1]
              finalUrls.push match[1]
              return o =
                key: match[1]
                value: title.trim()
            console.log 'No match: ', href
        .call "filter", (href) ->
          href?.key?
          
      .then (pubUrls) ->
        console.log 'Outer loop done', JSON.stringify pubUrls


    console.log 'promise', @jsPromise

qs = new QuickScrape config


# vim: set ts=2 sts=2 sw=2 et:
