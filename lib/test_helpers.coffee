require 'colors'
fs     = require 'fs'
path   = require 'path'
glob   = require 'glob'
rimraf = require 'rimraf'
W      = require 'when'
nodefn = require 'when/node'
run    = require('child_process').exec
_      = require 'lodash'

###*
 * @class Helpers
 * @classdesc a collection of useful test helper functions for
 * roots extensions
###

class Helpers
  constructor: (opts = {}) ->

    _path = (f) ->
      if opts.base? then path.join(opts.base, f) else f

    @file =
      exists: (f) ->
        fs.existsSync(_path(f))
      doesnt_exist: (f) ->
        !fs.existsSync(_path(f))
      has_content: (f) ->
        fs.readFileSync(_path(f), 'utf8').length > 0
      is_empty: (f) ->
        fs.readFileSync(_path(f), 'utf8').length < 1
      contains: (f, content) ->
        fs.readFileSync(_path(f), 'utf8').indexOf(content) > -1
      contains_match: (f, regex) ->
        !!fs.readFileSync(_path(f), 'utf8').match(regex)
      matches_file: (f, expected) ->
        f = _path(f)
        expected = _path(expected)
        String(fs.readFileSync(f)) == String(fs.readFileSync(expected))

    @directory =
      is_directory: (dir) ->
        fs.statSync(_path(dir)).isDirectory()
      exists: (dir) ->
        dir = _path(dir)
        try stat = fs.statSync(dir)
        catch err then return false
        stat.isDirectory() and fs.existsSync(dir)
      doesnt_exist: (dir) ->
        !fs.existsSync(_path(dir))
      has_contents: (dir) ->
        fs.readdirSync(_path(dir)).length > 0
      is_empty: (dir) ->
        fs.readdirSync(_path(dir)).length < 1
      contains_file: (dir, file) ->
        _.contains(fs.readdirSync(_path(dir)), file)
      matches_dir: (dir, expected) ->
        dir = _path(dir)
        expected = _path(expected)
        String(fs.readdirSync(dir)) == String(fs.readdirSync(expected))

    @project =
      compile: (Roots, p, cb) ->
        project = new Roots(_path(p))
        project.on('error', cb)
        project.on('done', cb)
        project.compile()
      remove_folders: (matcher) ->
        rimraf.sync(dir) for dir in glob.sync(_path(matcher))
      install_dependencies: (base, cb) ->
        tasks = []

        for d in glob.sync("#{base}/package.json")
          p = path.dirname(d)
          if fs.existsSync(path.join(p, 'node_modules')) then continue
          tasks.push nodefn.call(run, "npm i", { cwd: p })

        if tasks.length then console.log 'installing test dependencies...'.grey

        W.all(tasks).then(-> console.log(''); cb())

module.exports = Helpers
