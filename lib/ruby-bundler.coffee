RubyBundlerView = require './ruby-bundler-view'
RubyBundlerGemsView = require './ruby-bundler-gems-view'
{BufferedProcess, CompositeDisposable} = require 'atom'
fs = require('fs')
_ = require('underscore')

module.exports =
  rubyBundlerView: null
  rubyBundlerGemsView: null
  bufferedProcess: null
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      "ruby-bundler:install": => @bundle(state)
      "ruby-bundler:close": => @deactivate()
      #"ruby-bundler:list": => @list(state)

  checkForGemfile: (success, failure) ->
    gemfileFound = false
    for path in atom.project.getPaths()
      unless gemfileFound
        fs.exists "#{path}/Gemfile", (exists) =>
          if exists
            gemfileFound = true
            success(path)
    failure() unless gemfileFound

  checkForAndSetupRbenv: (callback) ->
    if fs.existsSync "#{process.env.HOME}/.rbenv"
      exec('eval "$(rbenv init -)"; rbenv rehash', callback())
    else
      callback()

  bundle: (state) ->
    @rubyBundlerView = new RubyBundlerView(state.rubyBundlerViewState)
    @checkForGemfile (path) =>
      @rubyBundlerView.bundling()

      command = 'bundle'
      args = []
      options =
        cwd: path
        env: process.env
      stdout = (output) =>
        @rubyBundlerView.appendOutput(output)
      stderr = (output) =>
        @rubyBundlerView.appendOutput(output)
      exit = (code) =>
        if code is 0 then @rubyBundlerView.success() else @rubyBundlerView.error()

      @bufferedProcess = new BufferedProcess({command, args, options, stdout, stderr, exit})
    , =>
      @rubyBundlerView.gemfileNotFound()

  list: (state) ->
    @rubyBundlerGemsView = new RubyBundlerGemsView()
    @checkForGemfile (path) =>
      command = 'bundle'
      args = ['list']
      options =
        cwd: path
        env: process.env
      stdout = (output) =>
        gems = []
        _.each output.split("\n"), (gemLine) ->
          match = gemLine.match(/\s+\* ([\w-\.]+) \((.+)\)/)
          if match?
            gems.push({name: match[1], version: match[2]})
        @rubyBundlerGemsView.addGems(gems)
      stderr = (output) =>
        # TODO: display error message
      @bufferedProcess = new BufferedProcess({command, args, options, stdout, stderr})
    , =>
      @rubyBundlerGemsView.setError("No Gemfile found")


  deactivate: ->
    @rubyBundlerView?.destroy()
    @rubyBundlerGemsView?.cancel()
