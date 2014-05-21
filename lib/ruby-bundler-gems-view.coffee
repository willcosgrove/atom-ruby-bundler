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
    #exec("atom `bundle show #{item.name}`")
    # Not sure what this should do
    # atom.open(bundle show #{item.name})
    command = 'bundle'
    args = ["show",item.name]
    options =
      cwd: atom.project.getPath()
      env: process.env
    stdout = (output) =>
      console.log(output)
      command = 'atom'
      args = [output]
      options =
        cwd: atom.project.getPath()
        env: process.env
      stdout = (output) =>
        console.log(output)
      stderr = (output) =>
        console.log(output)
      exit = (code) =>
        console.log(code)

      new BufferedProcess({command, args, options, stdout, stderr, exit})

    stderr = (output) =>
      console.log(output)
    exit = (code) =>
      console.log(code)

    @bufferedProcess = new BufferedProcess({command, args, options, stdout, stderr, exit})
    #atom.workspace.open("#{atom.project.getPath()}/Gemfile")
    @cancel()
