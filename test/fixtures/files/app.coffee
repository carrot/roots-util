RootsUtil = require '../../..'

test = ->
  class TextExtension
    constructor: (@roots) ->
      @util = new RootsUtil(@roots)
      @roots.emit('test', @util.files('*.html'))

module.exports =
  ignores: ['ignoreme.html']
  extensions: [test()]
