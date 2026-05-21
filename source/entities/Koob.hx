package entities;

import flixel.FlxSprite;
import iso.IsoSprite;
import flixel.util.FlxColor;

/**
 * The all powerful Koob
 *
 * Useful as a voxel for debugging the mind-bending world of isometric space.
 * Don't forget your 3D glasses!
 */
class Koob extends IsoSprite {
	public function new(X:Float, Y:Float) {
		gridWidth = 1;
		gridLength = 1;
		gridHeight = 1;

		super(X, Y);
		color = FlxColor.BLUE;

		sprite = new FlxSprite(AssetPaths.Block_5x5x10__png);
		sprite.offset.set(10, 20);

        // TODO Do we need to make both immovable?
        immovable = true;
        sprite.immovable = true;
	}
}
