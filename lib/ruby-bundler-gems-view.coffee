{SelectListView} = require 'atom'

module.exports =
class RubyBundlerGemsView extends SelectListView
  initialize: ->
    super
    @addClass('overlay from-top')
    atom.workspaceView.append(this)
    @focusFilterEditor()

  setGems: (gems) ->
    @setItems(gems)
    @populateList()

  viewForItem: (item) ->
    "<li>#{item.name}<span class='inline-block highlight-info pull-right'>#{item.version}</span></li>"

  getFilterKey: ->
    "name"
