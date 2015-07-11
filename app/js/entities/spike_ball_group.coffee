config = require '../config.coffee'

class SpikeBallGroup extends Phaser.Group
  tweenAngles: [
    [45, 0, -45, 0]
    [-45, 0, 45, 0]
  ]

  tweenTime: 1000

  constructor: (game)->
    super(game, game.world, 'SpikeBalls', false, true, Phaser.Physics.P2JS)

  createByCoords: (coords)->
    for coord, index in coords
      continue if index in [0, 1]

      x = if (index + 1) % 2 == 0 then coord.x + 15 else coord.x + 150

      spike_ball = @create(x, coord.y, 'sprites', 'spike_ball.png')

      spike_ball.anchor.set(0.5, 0)

      @.setShapes(spike_ball)

      spike_ball.body.debug = config.bodyDebug

      # для нормальной работы колайдеров
      spike_ball.body.dynamic = false
      spike_ball.body.kinematic = true


    @.setTweens()

  setShapes: (spike_ball)->
    spike_ball.body.clearShapes()

    spike_ball.body.addRectangle(5, 70, 0, 35)
    spike_ball.body.addCircle(22, 0, 106)

  setTweens: ->
    for spike_ball, index in @children
      continue if (index + 1) % 2 == 0

      angles = (
        switch index
          when 0
            @tweenAngles[0]
          when 2
            @tweenAngles[1]
          else
            @tweenAngles[Math.round(Math.random() * (1 - 0) + 0)]
      )

      tween = @game.add.tween(spike_ball.body)
        .to(angle: angles[0], @tweenTime, Phaser.Easing.Cubic.Out)
        .to(angle: angles[1], @tweenTime, Phaser.Easing.Cubic.In)
        .to(angle: angles[2], @tweenTime, Phaser.Easing.Cubic.Out)
        .to(angle: angles[3], @tweenTime, Phaser.Easing.Cubic.In)
        .delay(if index > 3 then Math.round(Math.random() * (1000 - 500) + 500) else 0)
        .loop()

      tween.spriteIndex = index

      tween.onUpdateCallback(
        (tween)->
          # задействуем твин на парный спайк
          @children[tween.spriteIndex + 1].body.angle = tween.target.sprite.angle
        @
      )

      tween.onStart.addOnce(
        (target, tween)->
          tween.delay(0)
        @
      )

      tween.start()

module.exports = SpikeBallGroup