path   = require 'path'
fs     = require 'fs'
should = require 'should'
glob   = require 'glob'
rimraf = require 'rimraf'
Roots  = require 'roots'
_path  = path.join(__dirname, 'fixtures')

# setup, teardown, and utils

should.file_exist = (path) ->
  fs.existsSync(path).should.be.ok

should.have_content = (path) ->
  fs.readFileSync(path).length.should.be.above(1)

should.contain = (path, content) ->
  fs.readFileSync(path, 'utf8').indexOf(content).should.not.equal(-1)

compile_fixture = (fixture_name, done) ->
  @path = path.join(_path, fixture_name)
  @public = path.join(@path, 'public')
  project = new Roots(@path)
  project.compile().on('error', done).on('done', done)

after ->
  rimraf.sync(public_dir) for public_dir in glob.sync('test/fixtures/**/public')

# tests

describe 'write', ->

  before (done) -> compile_fixture.call(@, 'write', done)

  it 'write utility function should work', ->
    p1 = path.join(@public, 'foo.html')
    p2 = path.join(@public, 'extra.html')
    should.file_exist(p1)
    should.file_exist(p2)
    should.have_content(p1)
    should.have_content(p2)

describe 'files', ->

  it 'should output a list of non-ignored files', (done) ->
    expects = 0

    p = path.join(_path, 'files')
    project = new Roots(p)
    project
      .on('error', done)
      .on('test', (r) ->
        ++expects
        r.length.should.equal(2)
        r[0].relative.should.eql('amaze.html')
        r[1].relative.should.eql('wow.html')
      ).on('done', (-> if expects then done() else done('not fired')))
      .compile()

describe 'output_path', ->

  it 'should output correct destination path', (done) ->
    expects = 0

    p = path.join(_path, 'output_path')
    project = new Roots(p)
    project
      .on('error', done)
      .on('test', (r) ->
        ++expects
        r.relative.should.eql('foo.html')
      ).on('done', (-> if expects then done() else done('not fired')))
      .compile()
