import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure_v2/components/collision_block.dart';
import 'package:pixel_adventure_v2/components/custom_hitbox.dart';
import 'package:pixel_adventure_v2/components/saw.dart';
import 'package:pixel_adventure_v2/components/utils.dart';
import 'package:pixel_adventure_v2/components/fruit.dart';
import '../pixel_adventure.dart';

enum PlayerState { idle, running, jumping, falling, hit, appearing, dead }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  Player({position, this.character = "Ninja Frog"})
      : super(
            position:
                position); //we take in the position, then give the position to the superclass I guess?
  String character;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;

  final double stepTime = 0.05; 

  final double _gravity = 12.8;
  final double _jumpForce = 460;//N
  final double _terminalVelocity = 400;

  double horizontalMovement = 0.0;
  double moveSpeed = 100;
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offestY: 4,
    width: 14,
    height: 28,
  );
  bool isOnGround = true;
  bool hasJumped = false;
  bool gotHit = false;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    //debugMode = true;
    startingPosition = Vector2(position.x, position.y);
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offestY),
      size: Vector2(hitbox.width, hitbox.height), 
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotHit){
    _updatePlayerState();
    _updatePlayerMovement(dt);
    _checkHorizontalCollision();
    _applyGravity(dt);
    _checkVerticalCollisions();
    }
    super.update(dt);
  }

//! Controls here
  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0.0;
    final isLeftKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
            keysPressed.contains(LogicalKeyboardKey.keyA);
    final isRightKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
            keysPressed.contains(LogicalKeyboardKey.keyD);

 
    horizontalMovement += isLeftKeyPressed ? -1.0 : 0.0;
    horizontalMovement += isRightKeyPressed ? 1.0 : 0.0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Fruit){
      other.collidedWithPlayer();
    }
    if (other is Saw)_respawn();
    super.onCollision(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    runningAnimation = _spriteAnimation("Run", 12, true);
    idleAnimation = _spriteAnimation("Idle", 11, true);
    jumpingAnimation = _spriteAnimation("Jump", 1, true);
    fallingAnimation = _spriteAnimation("Fall", 1, true);
    hitAnimation = _spriteAnimation("Hit", 7, false);
    appearingAnimation = _specialSpriteAnimation("Appearing", 7, true);

    //listing all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
    };

    // set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int frames, bool isLooping) {
    //basicly meaing this is a function that returns a sprite animation
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: frames,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
        loop: isLooping,
      ),
    );
  }
    SpriteAnimation _specialSpriteAnimation(String state, int frames, bool isLooping) {
    //basicly meaing this is a function that returns a sprite animation
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: frames,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
        loop: isLooping,
      ),
    );
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    if (velocity.x < 0 && scale.x > 0){
      flipHorizontallyAroundCenter();
    }else if(velocity.x > 0 && scale.x < 0){
      flipHorizontallyAroundCenter();
    }
    if(velocity.y > 0) {PlayerState.falling ;}
    else if(velocity.y < 0) {PlayerState.jumping ;}

    //if moving current is running
    if (velocity.x != 0) {
      playerState = PlayerState.running;
    }
    current = playerState;
  }
  void _updatePlayerMovement(double dt) {
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;

    if (hasJumped && isOnGround) _playerJump(dt);
  }

  void _playerJump(double dt) { //! here is where I limit jump height too
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _checkHorizontalCollision() {
    for (final block in collisionBlocks){
      //collision handling

      if (!block.isPlatform){
        if (checkCollision(this, block)){
          if (velocity.x > 0){
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0){
            velocity.x = 0;
            position.x = block.x + hitbox.offsetX + hitbox.width + block.width;
            break;
          }
        }
      }
    }
  }
  
  void _applyGravity(double dt) {
  velocity.y += _gravity;
  velocity.y.clamp(-_jumpForce, _terminalVelocity);
  position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions(){
    for (final block in collisionBlocks){
      if (block.isPlatform){
        if(checkCollision(this, block)){
          if (velocity.y > 0){
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offestY;
            isOnGround = true;
            break;
          }
        }

      }
      else {
        if(checkCollision(this, block)){
          if (velocity.y > 0){
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offestY;
            isOnGround = true;
            break;
          }
          if(velocity.y < 0){
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offestY;
          }
        }
      }
    }
  }
  
  void _respawn() {
    // 50 is how long each frame takes, 7 is the number of frames
    const hitDuration = Duration(milliseconds: 50 * 7);
    gotHit = true;
    current = PlayerState.hit;
    Future.delayed(hitDuration, (){
      //gotHit = false;
      scale.x = 1;
      position = startingPosition -Vector2.all(32);
      current = PlayerState.appearing;
      Future.delayed(hitDuration, (){
        position = startingPosition;
        gotHit = false;
      },);
    });
  }

}

