Roots Util
----------

[![npm](http://img.shields.io/npm/v/roots-util.svg?style=flat)](http://badge.fury.io/js/roots-util) [![tests](http://img.shields.io/travis/carrot/roots-util/master.svg?style=flat)](https://travis-ci.org/carrot/roots-util) [![dependencies](http://img.shields.io/gemnasium/carrot/roots-util.svg?style=flat)](https://gemnasium.com/carrot/roots-util) [![Coverage Status](http://img.shields.io/coveralls/carrot/roots-util.svg?style=flat)](https://coveralls.io/r/carrot/roots-util?branch=master)

A utility that makes building roots extensions a little easier.

### Why should you care?

Roots extensions, while quite powerful, can be complex to build, and difficult if you don't understand how roots core works thoroughly. Roots util provides utilities you can use to abstract common functionality if/when you need it.

### Installation

```
npm install roots-util
```

### Usage

Roots-util simply provides a bunch of utility functions, which are documented below. Before using any of them, you want to create an instance of roots-util, typically by passing through the roots object from the constructor as such:

```coffee
RootsUtil = require 'roots-util'

class TestExtension
  constructor: (@roots) ->
    @util = new RootsUtil(@roots)
```

#### write(path, contents)

Writes a given relative path (starting at the roots public output directory) with the given content.

**Example:**  
```coffee
compile_hooks:
  write: => @util.write('testing.html', '<p>wow</p>')
```

This example will write to `public/testing.html` (or whatever the output directory was set to), and will also create any directories that were not already present. For example, if you wanted to write to `public/foobar/testing.html`, and the `foobar` directory didn't exist, it would create that directory rather than erroring out.

#### files(minimatch_str)

Given a minimatch string or array of minimatch strings, this function will grab all files in your roots project that match, excluding directories and files that were ignored by the roots config. Returns an array of [vinyl](https://github.com/wearefractal/vinyl)-wrapped files.

**Example:**  
```coffee
constructor: (roots) ->
  util = new RootsUtil(roots)
  @css_files = util.files('assets/css/**').map((f) -> f.relative)

fs: ->
  detect: (f) => @css_files.indexOf(f.relative) > -1
```

This example pulls all non-ignored files in the css directory and tests whether we have a match in the `fs.detect` function. There are many other ways this can be used, just a quick example here.

#### output_path(path, ext)

Given the path to a source file in a roots project, produces the output path that it will be written to. Accepts an optional extension override (by default will return with the same file extension as the input). Returns a [vinyl](https://github.com/wearefractal/vinyl)-wrapped file object.

**Example:**  
```coffee
compile_hooks: ->
  write: (ctx) =>
    out = @util.output_path(ctx.file.path).relative.split('.')
    out.splice(-1, 0, 'min')
    { path: out.join() }
```

In this example, we calculate the output path, add a `.min` extension, and pass that path in as the new path to be written. Again, contrived and this utility function can be used in many other ways, just a quick usage example.

#### with_extension(f, ext)

For use with the `detect` function, this is a helper that allows you to easily detect file extensions. Consider this a less powerful, but simpler version of the `files` helper. This function can accept a string or an array.

**Example:**  
```coffee
constructor: (@roots) ->
  @util = new RootsUtil(@roots)

fs: ->
  category: 'markdown'
  extract: true
  detect: (f) => @util.with_extension(f, ['md', 'markdown'])
```

### Test Helpers

Roots-Util also includes a number of test helpers that might make testing your extensions a bit easier. The test helpers can be accessed as seen below:

```coffee
path      = require 'path'
RootsUtil = require 'root-util'

# basic initialization
helpers = new RootsUtil.Helpers
# you can also initialize with a base fixtures directory, for example
helpers2 = new RootsUtil.Helpers(base: path.join(__dirname, 'fixtures'))
```

If you instantiate your helper with a base path, that base will be joined to any file path that's passed into any of the helper functions. Otherwise, you'll need to pass the full path. This `helpers` instance has a bunch of functions you can use to help out with your tests, documented below:

##### file.exists(path)
tests whether a file exists

##### file.doesnt_exist(path)
tests whether a file doesn't exist

##### file.has_content(path)
tests whether a file contains any content

##### file.is_empty(path)
tests whether a file contains no content

##### file.contains(path, string)
tests whether a file's contents contain a given string

##### file.contains_match(path, regex)
tests whether a file's content match a given regex

##### file.matches_file(path, path2)
tests whether a file's contents match a second file's contents

##### directory.is_directory(path)
tests whether a path is a directory

##### directory.exists(path)
tests whether a path is a directory and exists

##### directory.doesnt_exist(path)
tests whether a path does not exist

##### directory.has_contents(path)
tests whether a directory contains files

##### directory.is_empty(path)
tests whether a directory doesn't contain files

##### directory.contains_file(dirpath, filename)
tests whether a directory contains a file with a given filename

##### directory.matches_dir(path, path2)
tests whether a directory's contents match that of a second directory

##### project.compile(Roots, path)
returns a promise, compiles a roots project given the `Roots` class and a path for the project.

##### project.remove_folders(minimatchString)
given a minimatch string, removes all folders that match (good for removing public folders after tests have completed)

##### project.install_dependencies(baseDir, callback)
given a base directory (minimatch compatible), installs dependencies for any matches of `baseDir/package.json` then hits a callback

### License & Contributing

- Details on the license [can be found here](LICENSE.md)
- Details on running tests and contributing [can be found here](contributing.md)
