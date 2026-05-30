package states;

import flixel.math.FlxPoint;
import contracts.CounterContract;
import entities.Koob;
import iso.Overlap;
import iso.debug.Debug;
import iso.IsoSprite;
import iso.Grid;
import iso.topo.Tophographic;
import todo.TODO;
import flixel.group.FlxGroup;
import flixel.math.FlxRect;
import flixel.group.FlxGroup.FlxTypedGroup;
import entities.CameraTransition;
import levels.ldtk.Level;
import levels.ldtk.Ldtk.LdtkProject;
import achievements.Achievements;
import entities.Player;
import events.gen.Event;
import events.EventBus;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionableState;

using states.FlxStateExt;

class PlayState extends FlxTransitionableState {
	/*
     * Default template setup
	 */
	var collidableGroup = new FlxGroup();
	var activeCameraTransition:CameraTransition = null;

	// var transitions = new FlxTypedGroup<CameraTransition>();

	var ldtk = new LdtkProject();
	var level:Level;

	/*
	 * Isometric
	 */
	var graph:Topographic;
	var player:IsoSprite;

	override public function create() {
		super.create();

		bgColor = FlxColor.GRAY.getDarkened(.5);
		FlxG.camera.pixelPerfectRender = true;

		#if isodebug
		FlxG.camera.width = Std.int(FlxG.camera.width / 2);
		Debug.dbgCam = new FlxCamera(Std.int(camera.x + camera.width), 0, camera.width, camera.height, camera.zoom);
		Debug.dbgCam.bgColor = FlxColor.RED.getDarkened(0.6);
		FlxG.cameras.add(Debug.dbgCam, false);
		#end

		Achievements.onAchieve.add(handleAchieve);
		EventBus.subscribe(ClickCount, (c) -> {
			QLog.notice('I got me an event about ${c.count} clicks having happened.');
		});

		// QLog.error('Example error');
		TODO.sfx('exampleSound');

		graph = new Topographic();

		// Build out our render order
		// add(transitions);
		add(graph);

		loadLevel("Level_0");

		camera.scroll.set(-FlxG.camera.width / 2, -10);

		testContract();
	}

	function loadLevel(name:String) {
		unload();

		level = new Level(name);
		FmodPlugin.playSong(level.raw.f_Music);

		FlxG.worldBounds.copyFrom(level.terrainLayer.getBounds());

		// Add iso level entities
		for (x in 0...level.terrainLayer.widthInTiles) {
			for (y in 0...level.terrainLayer.heightInTiles) {
				var tIdx = level.terrainLayer.getTileIndex(x, y);
				// TODO Handle other tile types
				if (tIdx != 0) {
					var mIdx = level.terrainLayer.getMapIndex(x, y);
					var tPos = level.terrainLayer.getTilePos(mIdx);
					if (tPos != null) {
						var koob = new Koob(tPos.x, tPos.y);
						graph.add(koob);
						collidableGroup.add(koob);
					}
				}
			}
		}

		player = new Player(level.spawnPoint.x, level.spawnPoint.y);
		graph.add(player);
		graph.rebuild();
		collidableGroup.add(player);

		camera.follow(player.sprite);

		// for (t in level.camTransitions)p {
		// 	transitions.add(t);
		// }

		// for (_ => zone in level.camZones) {
		// 	if (zone.containsPoint(level.spawnPoint)) {
		// 		setCameraBounds(zone);
		// 	}
		// }

		EventBus.fire(new PlayerSpawn(player.x, player.y));
	}

	function unload() {
		// for (t in transitions) {
		// 	t.destroy();
		// }
		// transitions.clear();

		for (o in collidableGroup) {
			o.destroy();
		}
		collidableGroup.clear();

		// TODO Do we need a way to clear the graph on unload?
		graph.rebuild();
	}

	function handleAchieve(def:AchievementDef) {
		add(def.toToast(true));
	}

	override public function update(elapsed:Float) {
		Grid.drawGrid(level.terrainLayer.widthInTiles, level.terrainLayer.heightInTiles);
		graph.drawDebug();

		// TODO Is this needed?
		// FlxG.overlap(graph, graph, null, Overlap.isoCollide);
		FlxG.collide(collidableGroup, collidableGroup);

		super.update(elapsed);

		graph.rebuild();

		if (FlxG.mouse.justPressed) {
			EventBus.fire(new Click(FlxG.mouse.x, FlxG.mouse.y));

			// Move (teleport) player to mouse on click.
			var mPos = FlxG.mouse.getPosition();
			var mTmp = FlxPoint.get();
			Grid.isoToGrid(mPos.x, mPos.y, mTmp);
			player.setPosition(mTmp.x, mTmp.y);
		}

		// FlxG.collide(midGroundGroup, player);
		// handleCameraBounds();
	}

	// Used for transitioning camera between areas, not needed atm
	// function handleCameraBounds() {
	// 	if (activeCameraTransition == null) {
	// 		FlxG.overlap(player, transitions, (p, t) -> {
	// 			activeCameraTransition = cast t;
	// 		});
	// 	} else if (!FlxG.overlap(player, activeCameraTransition)) {
	// 		var bounds = activeCameraTransition.getRotatedBounds();
	// 		for (dir => camZone in activeCameraTransition.camGuides) {
	// 			switch (dir) {
	// 				case N:
	// 					if (player.y < bounds.top) {
	// 						setCameraBounds(camZone);
	// 					}
	// 				case S:
	// 					if (player.y > bounds.bottom) {
	// 						setCameraBounds(camZone);
	// 					}
	// 				case E:
	// 					if (player.x > bounds.right) {
	// 						setCameraBounds(camZone);
	// 					}
	// 				case W:
	// 					if (player.x < bounds.left) {
	// 						setCameraBounds(camZone);
	// 					}
	// 				default:
	// 					QLog.error('camera transition area has unsupported cardinal direction ${dir}');
	// 			}
	// 		}
	// 	}
	// }
	//
	// public function setCameraBounds(bounds:FlxRect) {
	// 	camera.setScrollBoundsRect(bounds.x, bounds.y, bounds.width, bounds.height);
	// }

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}

	function testContract() {
        var rpcUrl = "http://127.0.0.1:8545";
        var contractAddress = "0x5fbdb2315678afecb367f032d93f642f64180aa3";
		var privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"; // Anvil account #0

		var contract:CounterContract;

        CounterContract.create(rpcUrl, contractAddress, privateKey)
			.then(c -> {
				contract = c;
				return contract.get_value();
			})
			.then(v -> {
				trace("cur val: " + v);
				return contract.increment();
			})
			.then(_ -> {
				return contract.get_value();
			})
			.then(v -> {
				trace("new val: " + v);
			})
			.catchError(err -> {
				trace(err);
			});
	}
}
