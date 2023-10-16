import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure_v2/components/collision_block.dart';
import 'package:pixel_adventure_v2/components/player_hitbox.dart';
import 'package:pixel_adventure_v2/components/utils.dart';
import '../pixel_adventure.dart';

enum PlayerState { idle, running, jumping, falling, attacking, hurt, dead }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler {
  Player({position, this.character = "Ninja Frog"})
      : super(
            position:
                position); //we take in the position, then give the position to the superclass I guess?
  String character;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation jumpingAnimation;

  final double stepTime = 0.05; 

  final double _gravity = 12.8;
  final double _jumpForce = 460;//N
  final double _terminalVelocity = 400;

  double horizontalMovement = 0.0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  PlayerHitbox hitbox = PlayerHitbox(
    offsetX: 10,
    offestY: 4,
    width: 14,
    height: 28,
  );
  bool isOnGround = true;
  bool hasJumped = false;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    //debugMode = true;
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offestY),
      size: Vector2(hitbox.width, hitbox.height), 
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    _checkHorizontalCollision();
    _applyGravity(dt);
    _checkVerticalCollisions();
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

  void _loadAllAnimations() {
    runningAnimation = _spriteAnimation("Run", 12);
    idleAnimation = _spriteAnimation("Idle", 11);
    jumpingAnimation = _spriteAnimation("Jump", 1);
    fallingAnimation = _spriteAnimation("Fall", 1);

    //listing all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
    };

    // set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int frames) {
    //basicly meaing this is a function that returns a sprite animation
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: frames,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
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

}

