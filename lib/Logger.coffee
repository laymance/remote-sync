PlainMessageView = null
AutoHideTimer = null

module.exports =
class Logger
  constructor: (@title) ->

  showInPanel: (message, className) ->
    if atom.config.get("remote-sync-pro.logToAtomNotifications")
      if className == 'text-error'
        atom.notifications.addError("#{message}")
      else
        atom.notifications.addInfo("#{message}")

    if not @panel
      {MessagePanelView, PlainMessageView} = require "atom-message-panel"
      @panel = new MessagePanelView
        title: @title

    @panel.attach()
    msg = new PlainMessageView
      message: message
      className: className

    @panel.add msg

    @panel.setSummary
      summary: message
      className: className

    @panel.body.scrollTop(1e10)

    if atom.config.get("remote-sync-pro.foldLogPanel") and not @foldedPanel
      @panel.toggle()
      @foldedPanel = true

    msg

  log: (message) ->
    date = new Date
    startTime = date.getTime()
    notifymessage = "#{message}"
    message = "[#{date.toLocaleTimeString()}] #{message}"
    if atom.config.get("remote-sync-pro.logToAtomNotifications")
      atom.notifications.addInfo("#{notifymessage}")
    if atom.config.get("remote-sync-pro.logToConsole")
      console.log message
      ()->
        console.log "#{message} Complete (#{Date.now() - startTime}ms)"
    else
      if AutoHideTimer
        clearTimeout AutoHideTimer
        AutoHideTimer = null
      if ! atom.config.get("remote-sync-pro.logToAtomNotifications")
        msg = @showInPanel message, "text-info"
      ()=>
          endMsg = " Complete (#{Date.now() - startTime}ms)"
          if atom.config.get("remote-sync-pro.logToAtomNotifications")
            atom.notifications.addSuccess(endMsg)
          else
            msg.append endMsg
            @panel.setSummary
              summary: "#{message} #{endMsg}"
              className: "text-info"
            if atom.config.get("remote-sync-pro.autoHideLogPanel")
              AutoHideTimer = setTimeout @panel.close.bind(@panel), 1000

  error: (message) ->
    if atom.config.get("remote-sync-pro.logToAtomNotifications")
      atom.notifications.addError("#{message}")
    else
      @showInPanel "#{message}","text-error"
