path      = require 'path'
fs        = require 'fs'
node      = require 'when/node'
mkdirp    = require 'mkdirp'
glob      = require 'glob'
_         = require 'lodash'
minimatch = require 'minimatch'
File      = require 'fobject'

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
      .then(-> new File(output_path).write(contents))

  ###*
   * Given a minimatch string or array of minimatch strings, scans the
   * roots project for non-ignored file matches and returns an array `File`s.
   *
   * @param  {String|Array} files - string or array of minimatch strings
   * @return {File[]} all matching files
  ###

  files: (matchers) ->
    if not Array.isArray(matchers) then matchers = [matchers]

    res = []

    for matcher in matchers
      tmp = glob.sync(path.join(@roots.root, matcher))
      tmp = _.reject(tmp, (f) -> fs.statSync(f).isDirectory())
      tmp = tmp.map((f) => new File(f, base: @roots.root))
      tmp = _.reject tmp, (f) =>
        _.any(@roots.config.ignores, (i) -> minimatch(f.relative, i, dot: true))
      res = res.concat(tmp)

    return res

  ###*
   * Given the path to a source file in a roots project, produces the output
   * path that it will be written to. Returns a File object.
   *
   * @param  {String} _path - path to a file in the roots project source
   * @param  {String} ext - (optional) file extension override
   * @return {File} File obj representing where it will be written
  ###

  output_path: (_path, ext) ->
    file = new File(_path, base: @roots.root)
    out = if ext then @roots.config.out(file, ext) else @roots.config.out(file)
    new File(out, base: @roots.config.output_path())

  ###*
   * For use with detect, given an extension it will match all files with
   * appropriate extenstions.
   *
   * @param  {File} file - File obj passed from detect() function
   * @param  {String or Array} ext - file extension to match
   * @return {Boolean} whether the extension of the file matches the ext arg
  ###

  with_extension: (file, ext) ->
    _.contains(Array::concat(ext), path.extname(file.relative).substr(1))

module.exports = RootsUtil
module.exports.Helpers = require('./test_helpers')
