RubyBundlerView = require './ruby-bundler-view'
RubyBundlerGemsView = require './ruby-bundler-gems-view'
{BufferedProcess} = require 'atom'
fs = require('fs')
_ = require('underscore')

module.exports =
  rubyBundlerView: null
  bufferedProcess: null

  activate: (state) ->
    console.log state
    atom.workspaceView.command "ruby-bundler:install", => @bundle(state)
    atom.workspaceView.command "ruby-bundler:list", => @list(state)
    atom.workspaceView.command "ruby-bundler:close", => @deactivate()

  checkForGemfile: (success, failure) ->
    fs.exists "#{atom.project.getPath()}/Gemfile", (exists) =>
      if exists then success() else failure()

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
        gems = _.map output.split("\n").slice(1, -1), (gemLine) ->
          match = gemLine.match(/\s+\* ([\w-\.]+) \((.+)\)/)
          if match?
            {name: match[1], version: match[2]}
          else
            console.log(gemLine)
        @rubyBundlerGemsView.setGems(gems)
      stderr = (output) =>
        # TODO: display error message

      @bufferedProcess = new BufferedProcess({command, args, options, stdout, stderr})

  deactivate: ->
    @rubyBundlerView.destroy()
