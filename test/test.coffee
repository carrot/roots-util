path   = require 'path'
fs     = require 'fs'
should = require 'should'
glob   = require 'glob'
rimraf = require 'rimraf'
Roots  = require 'roots'
_path  = path.join(__dirname, 'fixtures')
Roots = require 'roots'
RootsUtil = require '..'

# setup, teardown, and utils

should.file_exist = (path) ->
  fs.existsSync(path).should.be.ok

should.have_content = (path) ->
  fs.readFileSync(path).length.should.be.above(1)

compile_fixture = (fixture_name, done) ->
  @path = path.join(_path, fixture_name)
  @public = path.join(@path, 'public')
  project = new Roots(@path)
  project.compile().on('error', done).on('done', done)

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

describe 'helpers', ->

  before ->
    @h1 = new RootsUtil.Helpers
    @h2 = new RootsUtil.Helpers(base: _path)

  it 'file.exists should work', ->
    @h1.file.exists(path.join(_path, 'helpers/wow.html')).should.be.ok
    @h2.file.exists('helpers/wow.html').should.be.ok
    @h1.file.exists(path.join(_path, 'helpers/sdfsf.html')).should.not.be.ok
    @h2.file.exists('helpers/sdfsf.html').should.not.be.ok

  it 'file.doesnt_exist should work', ->
    @h1.file.doesnt_exist(path.join(_path, 'helpers/flkdsfn.html')).should.be.ok
    @h2.file.doesnt_exist('helpers/sirjowe.html').should.be.ok
    @h1.file.doesnt_exist(path.join(_path, 'helpers/wow.html')).should.not.be.ok
    @h2.file.doesnt_exist('helpers/wow.html').should.not.be.ok

  it 'file.has_content should work', ->
    @h1.file.has_content(path.join(_path, 'helpers/wow.html')).should.be.ok
    @h2.file.has_content('helpers/wow.html').should.be.ok
    @h1.file.has_content(path.join(_path, 'helpers/empty.html')).should.not.be.ok
    @h2.file.has_content('helpers/empty.html').should.not.be.ok

  it 'file.is_empty should work', ->
    @h1.file.is_empty(path.join(_path, 'helpers/empty.html')).should.be.ok
    @h2.file.is_empty('helpers/empty.html').should.be.ok
    @h1.file.is_empty(path.join(_path, 'helpers/wow.html')).should.not.be.ok
    @h2.file.is_empty('helpers/wow.html').should.not.be.ok

  it 'file.contains should work', ->
    @h1.file.contains(path.join(_path, 'helpers/wow.html'), 'wow').should.be.ok
    @h2.file.contains('helpers/wow.html', 'wow').should.be.ok
    @h1.file.contains(path.join(_path, 'helpers/wow.html'), 'bang').should.not.be.ok
    @h2.file.contains('helpers/wow.html', 'bang').should.not.be.ok

  it 'file.contains_match should work', ->
    @h1.file.contains_match(path.join(_path, 'helpers/wow.html'), /wow/).should.be.ok
    @h2.file.contains_match('helpers/wow.html', /wow/).should.be.ok
    @h1.file.contains_match(path.join(_path, 'helpers/wow.html'), /blah/).should.not.be.ok
    @h2.file.contains_match('helpers/wow.html', /blah/).should.not.be.ok

  it 'file.matches_file should work', ->
    f1 = path.join(_path, 'helpers/wow.html')
    f2 = path.join(_path, 'helpers/second_wow.html')
    f3 = path.join(_path, 'helpers/empty.html')
    @h1.file.matches_file(f1, f2).should.be.ok
    @h2.file.matches_file('helpers/wow.html', 'helpers/second_wow.html').should.be.ok
    @h1.file.matches_file(f1, f3).should.not.be.ok
    @h2.file.matches_file('helpers/wow.html', 'helpers/empty.html').should.not.be.ok

  it 'directory.is_directory should work', ->
    @h1.directory.is_directory(path.join(_path, 'helpers/folda')).should.be.ok
    @h2.directory.is_directory('helpers/folda').should.be.ok
    @h1.directory.is_directory(path.join(_path, 'helpers/wow.html')).should.not.be.ok
    @h2.directory.is_directory('helpers/wow.html').should.not.be.ok

  it 'directory.exists should work', ->
    @h1.directory.exists(path.join(_path, 'helpers/folda')).should.be.ok
    @h2.directory.exists('helpers/folda').should.be.ok
    @h1.directory.exists(path.join(_path, 'helpers/dgdfgdfg')).should.not.be.ok
    @h2.directory.exists('helpers/dgdfgdfg').should.not.be.ok

  it 'directory.doesnt_exist should work', ->
    @h1.directory.doesnt_exist(path.join(_path, 'helpers/folda')).should.not.be.ok
    @h2.directory.doesnt_exist('helpers/folda').should.not.be.ok
    @h1.directory.doesnt_exist(path.join(_path, 'helpers/sdff')).should.be.ok
    @h2.directory.doesnt_exist('helpers/sehfewf').should.be.ok

  it 'directory.has_contents should work', ->
    @h1.directory.has_contents(path.join(_path, 'helpers/folda')).should.be.ok
    @h2.directory.has_contents('helpers/folda').should.be.ok

  # empty folders ignored by git, so this fails on travis
  it.skip 'directory.is_empty should work', ->
    @h1.directory.is_empty(path.join(_path, 'helpers/empty_folda')).should.be.ok
    @h2.directory.is_empty('helpers/empty_folda').should.be.ok

  it 'directory.contains_file should work', ->
    @h1.directory.contains_file(path.join(_path, 'helpers/folda'), 'stuff.html').should.be.ok
    @h2.directory.contains_file('helpers/folda', 'stuff.html').should.be.ok

  it 'directory.matches_dir should work', ->
    d1 = path.join(_path, 'helpers/folda')
    d2 = path.join(_path, 'helpers/identical_folda')
    @h1.directory.matches_dir(d1, d2).should.be.ok
    @h2.directory.matches_dir('helpers/folda', 'helpers/identical_folda').should.be.ok

  it 'project.compile should work', (done) ->
    @h1.project.compile Roots, path.join(_path, 'helpers'), =>
      @h1.directory.exists(path.join(_path, 'helpers/public')).should.be.ok
      done()

  it 'project.remove_folders should work', ->
    @h1.project.remove_folders(path.join(_path, '*/public'))
    @h1.directory.doesnt_exist(path.join(_path, 'helpers/public')).should.be.ok
    fs.mkdirSync(path.join(_path, 'helpers/public'))
    @h2.project.remove_folders('*/public')
    @h2.directory.doesnt_exist('helpers/public').should.be.ok

  it 'project.install_dependencies should work', (done) ->
    @h1.project.install_dependencies path.join(_path, 'helpers/deps'), =>
      node_modules = path.join(_path, 'helpers/deps/node_modules')
      @h1.directory.exists(node_modules).should.be.ok
      rimraf.sync(node_modules)
      done()
