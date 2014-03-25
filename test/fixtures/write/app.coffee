RootsUtil = require '../../..'

test = ->
  class TextExtension
    constructor: (@roots) ->
      @util = new RootsUtil(@roots)

    category_hooks: ->
      after: => @util.write('extra.html', '<p>extra filez!</p>')

module.exports =
  extensions: [test()]
