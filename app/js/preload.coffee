#Parse = require 'Parse'
Phaser = require 'Phaser'

config = require './config.coffee'

class Preload extends Phaser.State
  constructor: -> super

  preload: ->
    unless @game.device.desktop
      @game.scale.scaleMode = Phaser.ScaleManager.SHOW_ALL

      @game.scale.forceOrientation(false, true)

      @game.scale.enterIncorrectOrientation.add(@.handleIncorrect, @)

      @game.scale.leaveIncorrectOrientation.add(@.handleCorrect, @)

    # # Show loading screen
    @game.add.sprite(@game.world.centerX - 150, @game.world.centerY - 13, 'preloadBarWrapper')
    @load.setPreloadSprite(@add.sprite(@game.world.centerX - 148, @game.world.centerY - 12, 'preloadBar'))

    # # Initialize Parse
    # Parse.initialize '[Application ID]', '[JavaScript Key]'
    # Parse.Analytics.track 'load', {
    #   language: window.navigator.language,
    #   platform: window.navigator.platform
    # }

    # # Set up game defaults
    @stage.backgroundColor = '595959'

    # # Load game assets
    @load.pack 'main', config.pack

  create: ->
    @state.start 'Welcome'

  handleIncorrect: ()->
    return if @game.device.desktop

    document.getElementById("turn").style.display="block"

  handleCorrect: ()->
    return if @game.device.desktop

    document.getElementById("turn").style.display="none"

module.exports = Preload