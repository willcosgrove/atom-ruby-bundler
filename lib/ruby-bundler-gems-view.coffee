{SelectListView,BufferedProcess} = require 'atom'

module.exports =
class RubyBundlerGemsView extends SelectListView
  initialize: ->
    super
    @addClass('overlay from-top')
    atom.workspaceView.append(this)
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
    # find out full path for gem via bundle show
    command = 'bundle'
    args = ["show",item.name]
    options =
      cwd: atom.project.getPath()
      env: process.env
    stdout = (output) =>
      console.log(path: output)
      atom.open({pathsToOpen: [output.split("\n").shift()]})
    stderr = (output) =>
      console.log(output)
    exit = (code) =>
      console.log(code)

    new BufferedProcess({command, args, options, stdout, stderr, exit})

    # clear list view to provide feedback
    @cancel()
