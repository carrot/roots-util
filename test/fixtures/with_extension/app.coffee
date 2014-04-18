RootsUtil = require '../../..'

test = ->
  class TextExtension
    constructor: (@roots) ->
      @util = new RootsUtil(@roots)

    fs: ->
      category: 'test'
      extract: true
      detect: (f) => @util.with_extension(f, 'html')

    compile_hooks: ->
      category: 'test'
      write: (ctx) => false

module.exports =
  extensions: [test()]
