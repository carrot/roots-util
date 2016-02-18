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
      if opts.base? then path.join(opts.base, f) else path.normalize(f)

    _exists = (file, opts = { async: false }) ->
      if opts.async
        nodefn.call(fs.stat, file).then(-> true).catch(-> false)
      else
        try fs.statSync(file)?
        catch then false

    _asyncReadFile = (file) ->
      nodefn.call(fs.readFile, file, 'utf8')

    @file =
      exists: (f, opts) ->
        _exists(_path(f), opts)

      doesnt_exist: (f, opts = { async: false }) ->
        if opts.async
          _exists(_path(f), opts).then (exists) -> !exists
        else
          !_exists(_path(f))

      has_content: (f, opts = { async: false }) ->
        if opts.async
          _asyncReadFile(_path(f)).then (c) -> c.length > 0
        else
          fs.readFileSync(_path(f), 'utf8').length > 0

      is_empty: (f, opts = { async: false }) ->
        if opts.async
          _asyncReadFile(_path(f)).then (c) -> c.length < 1
        else
          fs.readFileSync(_path(f), 'utf8').length < 1

      contains: (f, content, opts = { async: false }) ->
        if opts.async
          _asyncReadFile(_path(f)).then (c) -> c.indexOf(content) > -1
        else
          fs.readFileSync(_path(f), 'utf8').indexOf(content) > -1

      contains_match: (f, regex, opts = { async: false }) ->
        if opts.async
          _asyncReadFile(_path(f)).then (c) -> !!c.match(regex)
        else
          !!fs.readFileSync(_path(f), 'utf8').match(regex)

      matches_file: (f, expected, opts = { async: false }) ->
        f = _path(f)
        expected = _path(expected)
        if opts.async
          W.all([_asyncReadFile(f), _asyncReadFile(expected)])
            .spread (f, expected) -> f == expected
        else
          String(fs.readFileSync(f)) == String(fs.readFileSync(expected))

    @directory =
      is_directory: (dir, opts = { async: false }) ->
        if opts.async
          nodefn.call(fs.stat, _path(dir)).then (s) -> s.isDirectory()
        else
          fs.statSync(_path(dir)).isDirectory()

      exists: (dir, opts = { async: false }) ->
        dir = _path(dir)
        if opts.async
          nodefn.call(fs.stat, dir)
            .then (s) -> s.isDirectory()
            .catch -> false
        else
          try stat = fs.statSync(dir)
          catch then return false
          stat.isDirectory()

      doesnt_exist: (dir, opts = { async: false }) ->
        if opts.async
          _exists(_path(dir), opts).then (exists) -> !exists
        else
          !_exists(_path(dir))

      has_contents: (dir, opts = { async: false }) ->
        if opts.async
          nodefn.call(fs.readdir, _path(dir)).then (d) -> d.length > 0
        else
          fs.readdirSync(_path(dir)).length > 0

      is_empty: (dir, opts = { async: false }) ->
        if opts.async
          nodefn.call(fs.readdir, _path(dir)).then (d) -> d.length < 1
        else
          fs.readdirSync(_path(dir)).length < 1

      contains_file: (dir, file, opts = { async: false }) ->
        if opts.async
          nodefn.call(fs.readdir, _path(dir)).then (d) -> _.includes(d, file)
        else
          _.includes(fs.readdirSync(_path(dir)), file)

      matches_dir: (dir, expected, opts = { async: false }) ->
        dir = _path(dir)
        expected = _path(expected)
        if opts.async
          W.all([nodefn.call(fs.readdir, dir), nodefn.call(fs.readdir, expected)])
            .spread (dir, expected) -> String(dir) == String(expected)
        else
          String(fs.readdirSync(dir)) == String(fs.readdirSync(expected))

    @project =
      compile: (Roots, p) ->
        Roots.analytics(disable: true)
        proj = new Roots(_path(p))
        proj.on('error', ->)
        proj.compile().then -> Roots.analytics(enable: true)

      remove_folders: (matcher, opts = { async: false }) ->
        if opts.async
          W.map nodefn.call(glob, _path(matcher)), (dir) ->
            nodefn.call(rimraf, dir)
        else
          rimraf.sync(dir) for dir in glob.sync(_path(matcher))

      install_dependencies: (base, cb) ->
        dirs = nodefn.call(glob, "#{_path(base)}/package.json")
        W.map dirs, (d) -> path.dirname(d)
          .then (dirs) ->
            W.filter dirs, (d) -> !_exists(path.join(d, 'node_modules'))
          .tap (tasks) ->
            if tasks.length then console.log 'installing test dependencies...'.grey
            W.map tasks, (d) -> nodefn.call(run, "npm i", { cwd: d })
          .then cb

module.exports = Helpers
