
import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure_v2/pixel_adventure.dart';

class Saw extends SpriteAnimationComponent with HasGameRef<PixelAdventure>{
  final bool isVeritcal;
  final double offsetNeg;
  final double offsetPos;
  Saw({
    this.isVeritcal = false,
    this.offsetNeg = 0, 
    this.offsetPos = 0,
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  static const stepTime = 0.03;
  static const moveSpeed = 50;
  static const tileSize = 16;
  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    add(CircleHitbox());

    if(isVeritcal){
      rangeNeg = position.y - offsetNeg * tileSize;
      rangePos = position.y + offsetPos * tileSize;
    }else{
      rangeNeg = position.x - offsetNeg * tileSize;
      rangePos = position.x + offsetPos * tileSize;
    }

    animation = SpriteAnimation.fromFrameData(game.images.fromCache('Traps/Saw/On (38x38).png'), SpriteAnimationData.sequenced(
      amount: 8,
      stepTime: 0.03,
      textureSize: Vector2.all(38),
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isVeritcal) {
      _moveVertically(dt);
    }else{
      _moveHorizontally(dt);
    }
    super.update(dt);
  }
  //?? In case bug persists visit: https://youtu.be/t244FY8Ayq4?list=PLRRATgFqhVCh8qD7xmaSbwG1vfaCddvCM&t=1472
  void _moveVertically(double dt) {
    if (position.y >= rangePos || position.y <= rangeNeg){
      moveDirection *= -1;
    }
    position.y += moveSpeed * moveDirection * dt;
  }
  
  void _moveHorizontally(double dt) {
    if (position.x >= rangePos || position.x <= rangeNeg){
      moveDirection *= -1;
    }
    position.x += moveSpeed * moveDirection * dt;
  }
}