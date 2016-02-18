path      = require 'path'
fs        = require 'fs'
node      = require 'when/node'
mkdirp    = require 'mkdirp'
glob      = require 'glob'
_         = require 'lodash'
minimatch = require 'minimatch'
File      = require 'vinyl'

class RootsUtil
  constructor: (@roots) ->

  ###*
   * Given a path relative to the roots output folder and contents, writes
   * the contents to the given path, recursively creating any directories in
   * the path that have not yet been created.
   *
   * @param  {String} _path - relative path to write destination
   * @param  {String} contents - what to write to the file
   * @return {Promise} a promise for the written file
  ###

  write: (_path, contents) ->
    output_path = path.join(@roots.config.output_path(), _path)

    node.call(mkdirp, path.dirname(output_path))
      .then(-> node.call(fs.writeFile, output_path, contents))

  ###*
   * Given a minimatch string or array of minimatch strings, scans the
   * roots project for non-ignored file matches and returns an array of
   * vinyl-wrapped files.
   *
   * @param  {String or Array} files - string or array of minimatch strings
   * @return {Array} all matching files, in vinyl objects
  ###

  files: (matchers) ->
    if not Array.isArray(matchers) then matchers = [matchers]

    res = []

    for matcher in matchers
      tmp = glob.sync(path.join(@roots.root, matcher))
      tmp = _.reject(tmp, (f) -> fs.statSync(f).isDirectory())
      tmp = tmp.map((f) => new File(base: @roots.root, path: f))
      tmp = _.reject tmp, (f) =>
        _.some(@roots.config.ignores, (i) -> minimatch(f.relative, i, { dot: true }))
      res = res.concat(tmp)

    return res

  ###*
   * Given the path to a source file in a roots project, produces the output
   * path that it will be written to. Returns a vinyl-wrapped file object.
   *
   * @param  {String} _path - path to a file in the roots project source
   * @param  {String} ext - (optional) file extension override
   * @return {File} vinyl file obj representing where it will be written
  ###

  output_path: (_path, ext) ->
    f = new File(base: @roots.root, path: path.join(@roots.root, _path))
    out = if ext then @roots.config.out(f, ext) else @roots.config.out(f)
    new File(base: @roots.config.output_path(), path: out)

  ###*
   * For use with detect, given an extension it will match all files with
   * appropriate extenstions.
   *
   * @param  {File} file - a vinyl file obj passed from detect() function
   * @param  {String or Array} ext - file extension to match
   * @return {Boolean} whether the extension of the file matches the ext arg
  ###

  with_extension: (file, ext) ->
    _.includes(Array::concat(ext), path.extname(file.relative).substr(1))

module.exports = RootsUtil
module.exports.Helpers = require('./test_helpers')
