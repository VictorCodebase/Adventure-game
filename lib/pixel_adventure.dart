import 'dart:async';
//import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure_v2/components/player.dart';
import 'package:pixel_adventure_v2/components/level.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late final CameraComponent cam;
  Player player = Player(character: "Ninja Frog"); //default character
  late JoystickComponent joystick;

  // TODO: Allow users to change to joystick in settings
  bool showJoystick = false;

  @override
  FutureOr<void> onLoad() async {
    //To ensure characters are loaded into cache first
    await images.loadAllImages();
    final world = Level(
      player: player,
      levelName: 'Level-01',
    );

    cam = CameraComponent.withFixedResolution(
        world: world, width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam, world]);

    if (showJoystick){
    addJoystick();
    }
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoystick){
    updateJoystick();
    }
    super.update(dt);
  }


  void addJoystick() {
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/knob.png'),
        ),
      ),
      knobRadius: 58,
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );

    add(joystick);
  }
  
  void updateJoystick() {
    switch(joystick.direction){
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1.0;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
      player.horizontalMovement = 1.0;
        break;
      default:
        player.horizontalMovement = 0.0;
    }
  }

  void goToNextLevel() {
    final world = Level(
      player: player,
      levelName: 'Level-02',
    );
    cam.world = world;
    //joystick.remove();
    add(world);
  }
}
