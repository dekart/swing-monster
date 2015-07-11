config = require '../config.coffee'

class Player extends Phaser.Sprite
  isFlying: false
  padded: false
  win: false

  constructor: (game, x, y, type)->
    super(game, x, y, sessionData.monster)

    @game.world.add(@)

    @anchor.set(0.5, 0.5)

    @game.physics.p2.enable(@, config.bodyDebug)

    @body.setZeroDamping()
    @body.setZeroForce()
    @body.setZeroRotation()

    @body.clearShapes()

    @body.loadPolygon('physicsData', sessionData.monster);

    @animations.add('fly', [0,1,2,3,4,5,6,7], 10, true)



module.exports = Player