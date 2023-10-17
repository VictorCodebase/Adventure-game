import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure_v2/components/custom_hitbox.dart';
import 'package:pixel_adventure_v2/pixel_adventure.dart';

class Fruit extends SpriteAnimationComponent with HasGameRef<PixelAdventure>,
CollisionCallbacks{
  final String fruit;
  Fruit({
    this.fruit = 'Apple',
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );
  
  bool _collected = false;
  final double stepTime = 0.05;
  final hitBox = CustomHitbox(
    offsetX: 10,
    offestY: 10,
    width: 12,
    height: 12,
  );

  @override
  FutureOr<void> onLoad() {
    //debugMode = true;
    priority = -1;
    
    add(RectangleHitbox(
      position: Vector2(
        hitBox.offsetX,
        hitBox.offestY,
      ),
      size: Vector2(
        hitBox.width,
        hitBox.height,
      ),
      collisionType: CollisionType.passive,
      ),
    );

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/$fruit.png'),
      SpriteAnimationData.sequenced(
        amount: 17,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }
  //FIXME: I do not return onload here, but I do in the other components. Why?
  
  void collidedWithPlayer() {
    if (!_collected){
        animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/Collected.png'),
      SpriteAnimationData.sequenced(
        amount: 7,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
        loop: false,
      ),
    );
    _collected = true;
    }
    Future.delayed(const Duration(milliseconds: 400),
    (){
      removeFromParent();
    });
  }

}
