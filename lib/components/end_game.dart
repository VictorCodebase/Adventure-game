import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure_v2/components/custom_hitbox.dart';
import 'package:pixel_adventure_v2/pixel_adventure.dart';

class EndGame extends SpriteAnimationComponent with HasGameRef<PixelAdventure>,
CollisionCallbacks{

EndGame({
  position,
  size,
}) : super(
      position: position,
      size: size,
    );

    final double stepTime = 0.05;
    final hitBox = CustomHitbox(
      offsetX: 10,
      offestY: 10,
      width: 12,
      height: 12,
    );

    @override
  FutureOr<void> onLoad() {
    debugMode = true;
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
      game.images.fromCache('Items/Checkpoints/End 2/Nxt Level (Moving) (64x64).png'),
      SpriteAnimationData.sequenced(
        amount: 17,
        stepTime: stepTime,
        textureSize: Vector2.all(64),
      ),
    );
    return super.onLoad();
  }

}