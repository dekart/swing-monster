Phaser = require 'Phaser'

config = require './config.coffee'

class Welcome extends Phaser.State
  constructor: -> super

  preload: ->
    #@game.time.advancedTiming = true

  create: ->
    @game.add.sprite(0, 0, 'background')

    @game.add.sprite(0, 200, "sprites", "ground_#{ 1 }.png").anchor.set(0, 1)
    @game.add.sprite(0, 550, "sprites", "ground_#{ 4 }.png").anchor.set(0, 1)
    @game.add.sprite(352, 200, "sprites", "ground_#{ 3 }.png").anchor.set(0, 1)
    @game.add.sprite(352, 550, "sprites", "ground_#{ 4 }.png").anchor.set(0, 1)

    title = @game.add.image(
      Math.round(config.width / 2),
      100,
      "sprites"
      "swing_monster.png"
    )
    title.fixedToCamera  = true
    title.anchor.set(0.5, 0.5)

    playButton = @game.add.button(
      Math.round(config.width / 2),
      450,
      'sprites',
      @.onPlayButtonClick, @,
      "button_play_0.png",
      "button_play_0.png",
      "button_play_1.png"
    )
    playButton.fixedToCamera  = true
    playButton.anchor.set(0.5, 0.5)

    @.addPlayerSkillSelector()

  onPlayButtonClick: ->
    @state.start('Game')

  addPlayerSkillSelector: ->
    @playerSkills = []

    @playerSkillIndex = 0

    for type in ['a', 'b', 'c', 'd']
      monster_type = "monster_#{type}"

      sprite = @game.add.sprite(@game.world.centerX, 300, monster_type)
      sprite.anchor.set(0.5, 0.5)
      sprite.scale.set(1.1, 1.1)

      sprite.visible = false if sessionData.monster != monster_type

      sprite.animations.add('fly', [0,1,2,3,4,5,6,7], 10, true)

      sprite.play('fly')

      @game.add.tween(sprite)
        .to(y: "-5", 300, Phaser.Easing.Cubic.Out)
        .to(y: "+5", 300, Phaser.Easing.Cubic.Out)
        .loop()
        .start()

      @playerSkills.push(sprite)

    @leftButton = @game.add.button(
      Math.round(config.width / 2) - 100,
      300,
      'sprites',
      @.onLeftButtonClick, @,
      "left_1.png",
      "left_1.png",
      "left_1.png"
    )

    @leftButton.fixedToCamera  = true
    @leftButton.anchor.set(0.5, 0.5)

    @rightButton = @game.add.button(
      Math.round(config.width / 2) + 100,
      300,
      'sprites',
      @.onRightButtonClick, @,
      "right_0.png",
      "right_0.png",
      "right_1.png"
    )

    @rightButton.fixedToCamera  = true
    @rightButton.anchor.set(0.5, 0.5)

    text = @game.add.image(
      Math.round(config.width / 2),
      370,
      "sprites"
      "monster_skill.png"
    )
    text.fixedToCamera  = true
    text.anchor.set(0.5, 0.5)

  onLeftButtonClick: ->
    return if @playerSkillIndex <= 0

    @playerSkillIndex -= 1

    @.setSkill()

    @leftButton.setFrames("left_1.png", "left_1.png", "left_1.png") if @playerSkillIndex == 0
    @rightButton.setFrames("right_0.png", "right_0.png", "right_1.png") if @playerSkillIndex < @playerSkills.length - 1

  onRightButtonClick: ->
    return if @playerSkillIndex >= @playerSkills.length - 1

    @playerSkillIndex += 1

    @.setSkill()

    @rightButton.setFrames("right_1.png", "right_1.png", "right_1.png") if @playerSkillIndex >= @playerSkills.length - 1
    @leftButton.setFrames("left_0.png", "left_0.png", "left_1.png") if @playerSkillIndex > 0

  setSkill: ->
    for sprite, index in @playerSkills
      if @playerSkillIndex == index
        sprite.visible = true

        sessionData.monster = sprite.key
      else
        sprite.visible = false

  render: ->
    #@game.debug.text('fps='+(@game.time.fps || '--'), 2, 14, "#00ff00")

module.exports = Welcome