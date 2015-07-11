Phaser = require 'Phaser'

config = require './config.coffee'

class Boot extends Phaser.State
  constructor: -> super

  preload: ->
    @load.pack 'preload', config.pack

  create: ->
    @state.start 'Preload'

module.exports = Boot