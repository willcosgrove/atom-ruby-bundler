RubyBundlerView = require './ruby-bundler-view'
RubyBundlerGemsView = require './ruby-bundler-gems-view'
exec = require('child_process').exec
fs = require('fs')
_ = require('underscore')

module.exports =
  rubyBundlerView: null

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
      exec "cd #{atom.project.getPath()}; bundle", (error, stdout, stderr) =>
        if error
          @rubyBundlerView.setOutput(stdout)
          @rubyBundlerView.error()
        else
          @rubyBundlerView.setOutput(stdout)
          @rubyBundlerView.success()
    , =>
      @rubyBundlerView.gemfileNotFound()

  list: (state) ->
    @rubyBundlerGemsView = new RubyBundlerGemsView()
    @checkForGemfile =>
      exec "cd #{atom.project.getPath()}; bundle list", (error, stdout, stderr) =>
        if error
          #do something about it
        else
          gems = _.map stdout.split("\n").slice(1, -1), (gemLine) ->
            match = gemLine.match(/\s+\* ([\w-\.]+) \((.+)\)/)
            if match?
              {name: match[1], version: match[2]}
            else
              console.log(gemLine)
              {}
          @rubyBundlerGemsView.setGems(gems)

  deactivate: ->
    @rubyBundlerView.destroy()
