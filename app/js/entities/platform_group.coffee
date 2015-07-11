config = require '../config.coffee'

class PlatformGroup extends Phaser.Group
  constructor: (game)->
    super(game, game.world, 'Platforms', false, true, Phaser.Physics.P2JS)

    worldY = 2400
    worldX = 0

    while worldY > 100
      groundIndex = Math.round(Math.random() * (4 - 1) + 1)

      platform = @create(worldX, worldY, "sprites", "ground_#{ groundIndex }.png")

      platform.anchor.set(0, 1)

      @.changeBodyShape(platform)

      if worldX == 0
        worldX = 352
      else
        worldY -= 200
        worldX = 0

    @

  changeBodyShape: (platform)->
    platform.body.clearShapes()
    platform.body.addRectangle(platform.width - 1, 11, Math.round(platform.width / 2), -12)
    platform.body.static = true
    platform.body.debug = config.bodyDebug

  childCoords: ->
    child.position for child in @children

  setCollisionsData: (ownCollisionGroup, otherCollisionGroup)->
    @.forEach(
      (platform)->
        platform.body.setCollisionGroup(ownCollisionGroup)
        platform.body.collides(otherCollisionGroup)
      @
    )


module.exports = PlatformGroup