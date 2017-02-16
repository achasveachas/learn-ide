{$, View} = require 'atom-space-pen-views'
TerminalEmulator = require 'xterm'
TerminalEmulator.loadAddon 'fit'

module.exports =
class TerminalView extends View
  @content: ->
    @div class: 'terminal-resizer tool-panel', =>
      @div class: 'terminal-resize-handle', outlet: 'resizeHandle'
      @div class: 'terminal-container', outlet: 'emulatorContainer'

  initialize: (@terminal, @openPath) ->
    @emulator = new TerminalEmulator({cursorBlink: true})
    @subscribe()
    @attach()
    window.view = this

  subscribe: ->
    @emulator.on 'data', (data) =>
      @terminal.send(data)

    @terminal.on 'message', (msg) =>
      @emulator.write(msg)

    @on 'mousedown', '.terminal-resize-handle', (e) => @resizeStarted(e)

  attach: ->
    atom.workspace.addBottomPanel({item: this})
    @emulator.open(@emulatorContainer[0])

  resizeStarted: =>
    $(document).on('mousemove', @resizeTerminal)
    $(document).on('mouseup', @resizeStopped)

  resizeStopped: =>
    $(document).off('mousemove', @resizeTerminal)
    $(document).off('mouseup', @resizeStopped)

  resizeTerminal: ({pageY, which}) =>
    return @resizeStopped() unless which is 1

    height = @outerHeight() + @offset().top - pageY

    return if height < 100

    # resize container and fit emulator inside it
    @emulatorContainer.height(height - @resizeHandle.height())
    @emulator.fit()

    # then get emulator height and fit containers around it
    rowHeight = parseInt(@emulator.rowContainer.style.lineHeight)
    newHeight = rowHeight * @emulator.rows
    @emulatorContainer.height(newHeight)
    @height(newHeight + @resizeHandle.height())

