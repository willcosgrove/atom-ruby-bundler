{View} = require 'atom'

module.exports =
class RubyBundlerView extends View
  output: []

  @content: ->
    @div class: 'ruby-bundler overlay from-top', =>
      @div class: 'panel', =>
        @div class: 'panel-heading', =>
          @span outlet: 'heading', 'Ruby Bundler'
          @div class: 'btn-toolbar pull-right', =>
            @button class: 'btn close', 'X'
        @div class: 'panel-body padded', outlet: 'message'

  initialize: (serializeState) ->
    @on 'click', '.see-output', => @showMeTheMoney()
    @on 'click', '.close', => @destroy()
    this.hide()
    atom.workspaceView.append(this)
    atom.workspaceView.addClass('ruby bundler active')
    this.slideDown(100)

  bundling: ->
    @message.html View.render ->
      @div class: 'block', =>
        @progress class: 'inline-block'
        @span class: 'inline-block', 'Bundling...'

  gemfileNotFound: ->
    @message.html View.render ->
      @div class: 'text-error', "Gemfile could not be found"

  success: ->
    @message.html View.render ->
      @span 'Success!', class: 'text-success'
      @button class: 'btn see-output pull-right', 'See output'

  error: ->
    @message.html View.render ->
      @span 'Uhoh... something went wrong', class: 'text-error'
      @button class: 'btn see-output pull-right', 'See output'

  showMeTheMoney: ->
    console.log 'Viewing output'
    atom.workspace.open().then (editor) =>
      editor.buffer.append(@output.join("\n"))
      @destroy()

  appendOutput: (output) ->
    @output.push output

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    atom.workspaceView.removeClass('ruby bundler active')
    @detach()
