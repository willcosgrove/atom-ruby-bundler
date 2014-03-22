RubyBundlerView = require './ruby-bundler-view'
RubyBundlerGemsView = require './ruby-bundler-gems-view'
{BufferedProcess} = require 'atom'
fs = require('fs')
_ = require('underscore')

module.exports =
  rubyBundlerView: null
  bufferedProcess: null

  activate: (state) ->
    atom.workspaceView.command "ruby-bundler:install", => @bundle(state)
    atom.workspaceView.command "ruby-bundler:list", => @list(state)
    atom.workspaceView.command "ruby-bundler:close", => @deactivate()

  checkForGemfile: (success, failure) ->
    fs.exists "#{atom.project.getPath()}/Gemfile", (exists) =>
      if exists then success() else failure()

  checkForAndSetupRbenv: (callback) ->
    if fs.existsSync "#{process.env.HOME}/.rbenv"
      exec('eval "$(rbenv init -)"; rbenv rehash', callback())
    else
      callback()

  bundle: (state) ->
    @rubyBundlerView = new RubyBundlerView(state.rubyBundlerViewState)
    @checkForGemfile =>
      @rubyBundlerView.bundling()

      command = 'bundle'
      args = []
      options =
        cwd: atom.project.getPath()
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
    @checkForGemfile =>
      command = 'bundle'
      args = ['list']
      options =
        cwd: atom.project.getPath()
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

  deactivate: ->
    @rubyBundlerView.destroy()
