Phaser = require 'Phaser'

config = require './config.coffee'
Boot = require './boot.coffee'
Preload = require './preload.coffee'
Game = require './game.coffee'
Welcome = require './welcome.coffee'

window.sessionData = {
  monster: 'monster_a'
  coinsCollected: 0
  level: 1
}

game = new Phaser.Game(config.width, config.height, Phaser.AUTO, 'game')

game.state.add 'Boot', Boot
game.state.add 'Preload', Preload
game.state.add 'Welcome', Welcome
game.state.add 'Game', Game

game.state.start 'Boot'
