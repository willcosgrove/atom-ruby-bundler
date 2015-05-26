{$, SelectListView} = require 'atom-space-pen-views'

module.exports =
class RubyBundlerGemsView extends SelectListView
  initialize: ->
    super
    @addClass('overlay from-top')
    $(atom.views.getView(atom.workspace)).append(this)
    $(atom.views.getView(atom.workspace)).addClass('ruby bundler active')
    @focusFilterEditor()
    @gems = []

  addGems: (gems) ->
    @gems = @gems.concat(gems)
    @setItems(@gems)
    @populateList()

  viewForItem: (item) ->
    "<li>#{item.name}<span class='inline-block highlight-info pull-right'>#{item.version}</span></li>"

  getFilterKey: ->
    "name"

  confirmed: (item) ->
    # Not sure what this should do
    atom.workspace.open("#{atom.project.getPath()}/Gemfile")
    @cancel()
