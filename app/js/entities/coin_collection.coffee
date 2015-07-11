config = require '../config.coffee'

class CoinCollection extends Phaser.Group
  numbers: {
    "0": "number_1"
    "1": "number_2"
    "2": "number_3"
    "3": "number_4"
    "4": "number_5"
    "5": "number_6"
    "6": "number_7"
    "7": "number_8"
    "8": "number_9"
    "9": "number_10"
  }

  numberXOfsset: 75
  numberImageWidth: 28
  numberImageOriginalWidth: 42

  constructor: (game)->
    super(game, game.world, 'CoinCollection')

    @numberImages = []

    image = new Phaser.Image(@game, 10, 10, 'sprites', 'coin_collection.png')
    image.fixedToCamera = true
    image.scale.set(0.6, 0.6)

    @add(image)

    for index in [0...6]
      image = new Phaser.Image(@game, @.numberImageWidth * index + @.numberXOfsset, 23, 'sprites', "number_0.png")
      image.fixedToCamera = true
      image.visible = false
      image.scale.set(0.6, 0.6)
      image.anchor.set(0.5, 0.5)

      @add(image)

      @numberImages.push(image)

  showScore: ->
    scoreNumbers = new String(sessionData.coinsCollected).toString().split("")

    for image, index in @numberImages
      image.visible = false

      continue unless scoreNumbers[index]

      image.frameName = "number_#{ scoreNumbers[index] }.png"
      image.visible = true

  showGameOverScore: (group, offsetX)->
    scoreNumbers = new String(sessionData.coinsCollected).toString().split("")

    for number, index in scoreNumbers
      image = new Phaser.Image(@game, @.numberImageOriginalWidth * index + offsetX, 0, 'sprites', "number_#{number}.png")
      image.fixedToCamera = true
      image.anchor.set(0.5, 0.5)

      group.add(image)

module.exports = CoinCollection