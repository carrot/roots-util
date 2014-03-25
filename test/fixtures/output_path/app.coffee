RootsUtil = require '../../..'

test = ->
  class TextExtension
    constructor: (@roots) ->
      @util = new RootsUtil(@roots)
      @roots.emit('test', @util.output_path('views/foo.html'))

module.exports =
  extensions: [test()]
