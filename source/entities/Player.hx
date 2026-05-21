package entities;

import flixel.FlxSprite;
import iso.IsoSprite;
import flixel.util.FlxColor;
import input.InputCalculator;
import input.SimpleController;

class Player extends IsoSprite {
	var speed:Float = 150;
	var playerNum = 0;

	public function new(X:Float, Y:Float) {
		gridWidth = 1;
		gridLength = 1;
		gridHeight = 1;

		super(X, Y);
		color = FlxColor.GREEN;

		sprite = new FlxSprite(AssetPaths.Block_5x5x10__png);
		sprite.offset.set(10, 20);
	}

	override public function update(delta:Float) {
		super.update(delta);

		var inputDir = InputCalculator.getInputCardinal(playerNum);
		if (inputDir != NONE) {
			inputDir.asVector(velocity).scale(speed);
		} else {
			velocity.set();
		}
	}
}
