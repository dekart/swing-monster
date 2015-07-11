Phaser = require 'Phaser'

config = require './config.coffee'
levels = require './levels.coffee'

Player = require './entities/player.coffee'
PlatformGroup = require './entities/platform_group.coffee'
SpikeBallGroup = require './entities/spike_ball_group.coffee'
CoinGroup = require './entities/coin_group.coffee'
CoinCollection = require './entities/coin_collection.coffee'

class Game extends Phaser.State
  constructor: -> super

  preload: ->
    @game.time.advancedTiming = true

  create: ->
    @game.add.sprite(0, 0, 'background')

    @game.world.setBounds(0, 0, 512, 2637)

    @physics.startSystem(Phaser.Physics.P2JS)

    @physics.p2.setImpactEvents(true)
    @physics.p2.updateBoundsCollisionGroup()
    @physics.p2.restitution = 0

    @playerCollisionGroup     = @physics.p2.createCollisionGroup()
    @platformCollisionGroup   = @physics.p2.createCollisionGroup()
    @spikeBallsCollisionGroup = @physics.p2.createCollisionGroup()
    @coinsCollisionGroup      = @physics.p2.createCollisionGroup()

    @airExplode = @game.add.sprite(0, 0, 'air_explode')
    @airExplode.anchor.set(0.5, 0.5)
    @airExplode.visible = false
    @airExplode.animations.add('explode', null, 10)

    @platforms = new PlatformGroup(@game)

    @spikeBalls = new SpikeBallGroup(@game)

    @spikeBalls.createByCoords(@platforms.childCoords())

    @coins = new CoinGroup(@game)

    levelNumber = (
      if sessionData.level <= 30
        sessionData.level
      else
        Math.round(Math.random() * (30 - 5) + 5)
    )

    @coins.createByData(levels["level_#{ levelNumber }"].coins)

    @player = new Player(@game, @game.world.centerX, 2550, 'a')

    @camera.follow(@player, Phaser.Camera.FOLLOW_TOPDOWN)

    @coinCollection = new CoinCollection(@game)

    @coinCollection.showScore()

    @input.multiInputOverride = Phaser.Input.TOUCH_OVERRIDES_MOUSE

    @.setCollisions()

    @pauseButton = @game.add.button(
      config.width - 60,
      10,
      'sprites',
      @.onPauseClick, @,
      "pause_0.png",
      "pause_0.png",
      "pause_1.png"
    )
    @pauseButton.fixedToCamera  = true
    @pauseButton.visible = false

    @resumeButton = @game.add.button(
      Math.round(config.width / 2),
      310,
      'sprites',
      @.onResumeButtonClick, @,
      "button_resume_0.png",
      "button_resume_0.png",
      "button_resume_1.png"
    )
    @resumeButton.fixedToCamera  = true
    @resumeButton.anchor.set(0.5, 0.5)
    @resumeButton.visible = false

    @input.onDown.add(@.onDown, @) # должен идти последним

    if sessionData.level == 1
      @pathImage = @game.add.image(
        Math.round(config.width / 2),
        400,
        "sprites"
        "path.png"
      )
      @pathImage.fixedToCamera  = true
      @pathImage.anchor.set(0.5, 0.5)
      @pathImage.scale.set(0.75, 0.75)

      @initialText = @game.add.image(
        Math.round(config.width / 2),
        250,
        "sprites"
        "tap_to_play.png"
      )
      @initialText.fixedToCamera  = true
      @initialText.anchor.set(0.5, 0.5)

  setCollisions: ->
    @platforms.setCollisionsData(@platformCollisionGroup, @playerCollisionGroup)

    @spikeBalls.forEach(
      (spike_ball)->
        spike_ball.body.setCollisionGroup(@spikeBallsCollisionGroup)
        spike_ball.body.collides(@playerCollisionGroup)
      @
    )

    @coins.setCollisionsData(@coinsCollisionGroup, @playerCollisionGroup)

    @player.body.setCollisionGroup(@playerCollisionGroup)
    @player.body.collides([@spikeBallsCollisionGroup, @platformCollisionGroup], @.onEnemyCollide, @)
    @player.body.collides(@coinsCollisionGroup, @.onCoinsCollect, @)

  onDown: =>
    @pauseButton.visible = true unless @pauseButton.visible

    @initialText.visible = false if @initialText?
    @pathImage.visible = false if @pathImage?

    return if @player.padded || @player.win

    @player.isFlying = true unless @player.isFlying

    @player.play('fly')

    if @player.direction == 'left'
      @player.direction = 'right'

      @player.body.angle = 15
    else
      @player.direction = 'left'

      @player.body.angle = -15

  onCoinsCollect: (playerBody, otherBody)->
    playerBody.setZeroDamping()
    playerBody.setZeroForce()
    playerBody.setZeroRotation()

    otherBody.sprite.kill()

    sessionData.coinsCollected += 1

    @coinCollection.showScore()

  onEnemyCollide: (playerBody, otherBody)->
    @.gameOver()

    @player.body.clearCollision()
    @player.padded = true
    @player.isFlying = false
    @player.animations.stop('fly')
    @player.frame = 8 # hit frame

    hitPoint = new Phaser.Point(@player.x, @player.y)
    hitPoint.rotate(
      hitPoint.x,
      hitPoint.y,
      @math.angleBetween(@player.x, @player.y, otherBody.sprite.x, otherBody.sprite.y),
      false,
      40
    )

    @airExplode.reset(hitPoint.x, hitPoint.y)
    @airExplode.visible = true
    @airExplode.play('explode', null, 10, true)

  gameOver: ->
    @pauseButton.visible = false
    @input.onDown.remove(@.onDown, @)
    @game.tweens.removeAll()

    gameOverText = @game.add.image(Math.round(config.width / 2), 150, 'sprites', "game_over.png")
    gameOverText.fixedToCamera  = true
    gameOverText.anchor.set(0.5, 0.5)

    scoreGroup = @game.add.group()

    scoreImage = new Phaser.Image(@game, 0, 0, "sprites","coin_collection.png")
    scoreImage.fixedToCamera  = true
    scoreImage.anchor.set(0.5, 0.5)

    scoreGroup.add(scoreImage)

    @coinCollection.showGameOverScore(scoreGroup, 63)

    scoreGroup.x = Math.round(config.width / 2) - Math.round(scoreGroup.width / 2) + 42
    scoreGroup.y = 230

    replayButton = @game.add.button(
      Math.round(config.width / 2),
      310,
      'sprites',
      @.onReplayButtonClick, @,
      "button_replay_0.png",
      "button_replay_0.png",
      "button_replay_1.png"
    )
    replayButton.fixedToCamera  = true
    replayButton.anchor.set(0.5, 0.5)

  gameWin: ->
    @pauseButton.visible = false
    @player.isFlying = false
    @player.body.clearCollision()
    @player.win = true
    @player.animations.stop('fly')
    @player.frame = 0 # hit frame
    @player.body.angle = 0

    @input.onDown.remove(@.onDown, @)
    @game.tweens.removeAll()

    text = @game.add.image(
      Math.round(config.width / 2),
      250,
      "sprites"
      "you_won.png"

    )
    text.fixedToCamera  = true
    text.anchor.set(0.5, 0.5)
    text.shadowBlur = 1
    text.shadowColor = "#407104"
    text.shadowOffsetX = 1
    text.shadowOffsetY = 1

    playNextButton = @game.add.button(
      Math.round(config.width / 2),
      340,
      'sprites',
      @.onPlayNextButtonClick, @,
      "button_continue_0.png",
      "button_continue_0.png",
      "button_continue_1.png"
    )
    playNextButton.fixedToCamera  = true
    playNextButton.anchor.set(0.5, 0.5)


  onReplayButtonClick: ->
    sessionData.coinsCollected = 0
    sessionData.level = 1

    @state.restart('Game')

  onPlayNextButtonClick: ->
    sessionData.level += 1

    @state.restart('Game')

  onPauseClick: ->
    @input.onDown.active = false
    @game.physics.p2.paused  = true
    @game.tweens.pauseAll()

    @pauseButton.setFrames('pause_1.png', 'pause_1.png')

    @pauseButton.inputEnabled = false
    @resumeButton.visible = true

  onResumeButtonClick: ->
    @input.onDown.active = true
    @game.physics.p2.paused  = false
    @game.tweens.resumeAll()

    @pauseButton.inputEnabled = true
    @resumeButton.visible = false

    @pauseButton.setFrames('pause_0.png', 'pause_0.png')

  update: ->
    if @player.isFlying
      @player.body.moveUp(100)

      if @player.direction == 'right'
        @player.body.moveRight(150)
      else
        @player.body.moveLeft(150)

      @.gameWin() if @player.position.y < 100

    else
      @player.body.setZeroVelocity()
      @player.body.setZeroDamping()
      @player.body.setZeroForce()
      @player.body.setZeroRotation()

  render: ->
    @game.debug.text('fps='+(@game.time.fps || '--'), 2, 14, "#00ff00")

module.exports = Game