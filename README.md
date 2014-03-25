Roots Util
----------

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

##### write(path, contents)

Writes a given relative path (starting at the roots public output directory) with the given content.

**Example:**    
```coffee
compile_hooks:
  write: => @util.write('testing.html', '<p>wow</p>')
```

This example will write to `public/testing.html` (or whatever the output directory was set to), and will also create any directories that were not already present. For example, if you wanted to write to `public/foobar/testing.html`, and the `foobar` directory didn't exist, it would create that directory rather than erroring out.

##### files(minimatch_str)

Given a minimatch string, this function will grab all files in your roots project that match, excluding directories and files that were ignored by the roots config. Returns an array of [vinyl](https://github.com/wearefractal/vinyl)-wrapped files.

**Example:**     
```coffee
constructor: (roots) ->
  util = new RootsUtil(roots)
  @css_files = util.files('assets/css/**').map((f) -> f.relative)

fs: ->
  detect: (f) => @css_files.indexOf(f.relative) > -1
```

This example pulls all non-ignored files in the css directory and tests whether we have a match in the `fs.detect` function. There are many other ways this can be used, just a quick example here.

##### output_path(path)

Given the path to a source file in a roots project, produces the output path that it will be written to. Returns a [vinyl](https://github.com/wearefractal/vinyl)-wrapped file object.

**Example:**     
```coffee
compile_hooks: ->
  write: (ctx) =>
    out = @util.output_path(ctx.file.path).relative.split('.')
    out.splice(-1, 0, 'min')
    { path: out.join() }
```

In this example, we calculate the output path, add a `.min` extension, and pass that path in as the new path to be written. Again, contrived and this utility function can be used in many other ways, just a quick usage example.
