config = require '../config.coffee'

class CoinGroup extends Phaser.Group
  coinPools: {
    1  : [1]
    2  : [1, 1]
    3  : [1, 1, 1]
    4  : [1, 1, 1, 1]
    5  : [1, 1, 1, 1, 1]
    6  : [1, 1, 2, 1, 1]
    7  : [1, 1, 0, 1, 1]
    8  : [1, 1, 3, 1, 1]
    9  : [1, 1, 4, 1, 1]
    10  : [2, 1, 1]
    11  : [1, 2, 1]
    12  : [1, 1, 2]
    13 : [1, 3, 1]
    14 : [[true, true, false, false, true, true]],
    15 : [1, [true, true, false, false, true, true], 1]
    16 : [1, 1, 0, 0, 1, 1]
    17 : [1, 1, 0, 1, 1]
    18 : [1, 0, 1]
    19 : [2]
    20 : [3]
    21 : [3, 1]
    22 : [3, 1, 1]
    23 : [4]
    24 : [5]
  }

  coinOffset: {x: 40, y: 40}
  worldXOffset: 15

  constructor: (game)->
    super(game, game.world, 'Coins', false, true, Phaser.Physics.P2JS)

  createByData: (data)->
    for [startY, poolNumber] in data
      for pool, index in @coinPools[poolNumber]
        size = if typeof(pool) == "number" then pool else pool.length
        coinX = @game.world.centerX - Math.round((size * @coinOffset.x) / 2) + @worldXOffset

        if typeof(pool) == "number"
          for coinIndex in [0...pool]
            @.createCoin(coinX + (coinIndex * @coinOffset.x), startY + (index * @coinOffset.y))
        else
          for p, coinIndex in pool
            continue unless p

            @.createCoin(coinX + (coinIndex * @coinOffset.x), startY + (index * @coinOffset.y))


  createCoin: (coinX, coinY)->
    coin = @create(coinX, coinY, 'coin')

    coin.animations.add('rotation', null, 10, true)
    coin.play('rotation')

    coin.body.setCircle(12, 0, 4)

    coin.body.static = true

    coin.body.debug = config.bodyDebug

    coin

  setCollisionsData: (ownCollisionGroup, otherCollisionGroup)->
    @.forEach(
      (coin)->
        coin.body.setCollisionGroup(ownCollisionGroup)
        coin.body.collides(otherCollisionGroup)
      @
    )

module.exports = CoinGroup