//
//  MGWUMinigameTemplate
//
//  Created by Zachary Barryte on 6/6/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "MyMinigame.h"

@implementation MyMinigame {
    CCNode *_touchBox;
    CCNode *_touch;
    CCNode *_contentNode;
    CGFloat width;
    CGFloat height;
    BOOL moving;
    CCPhysicsNode *_physicsNode;
    CCNode *_followNode;
    CCAction *_moveScreen;
    NSMutableArray *_enemies;
    BOOL jumping;
    int newblock;
    int lastblock;
    CFTimeInterval starttime;
    CCLabelTTF *_label;
    int speed;
    
    //Bolt *_enemy;
}

-(id)init {
    if ((self = [super init])) {
        // Initialize any arrays, dictionaries, etc in here
        self.instructions = @"Dont fall behind is a game where you have to stay on the screen and jump on the enemies.  You control by using your thumb as a joystick.  Have fun.";
    }
    return self;
}

-(void)didLoadFromCCB {
    // Set up anything connected to Sprite Builder here
    
    // We're calling a public method of the character that tells it to jump!
    
}

-(void)onEnter {
    speed = 100;

    lastblock = 450;
    newblock = 300;
    [super onEnter];
    //[self.hero jump];
    self.userInteractionEnabled = true;
    width = [UIScreen mainScreen].bounds.size.width;
    height = [UIScreen mainScreen].bounds.size.height;
    _physicsNode.debugDraw = TRUE;
    _physicsNode.collisionDelegate = self;
    _followNode.physicsBody.collisionMask = @[];
    _followNode.physicsBody.velocity = ccp(speed,0);
    self.contentSize = CGSizeMake(7000, self.contentSize.height);
    _contentNode.contentSize = self.contentSize;
    _moveScreen = [CCActionFollow actionWithTarget:_followNode worldBoundary:_contentNode.boundingBox];
    [_contentNode runAction:_moveScreen];
    _enemies = [NSMutableArray new];
    starttime = CACurrentMediaTime();
    // perform some action
    
    
    
    


    
    for (int i = 0; i < 2; i++) {
        CCSprite *_newthing = [CCBReader load:[NSString stringWithFormat:@"JoeyThamanIce%d", ((arc4random()%6)+1)]];
        _newthing.position = ccp(100+(i+1)*newblock, 75+arc4random()%100);
        _newthing.scale = 3;
        [_physicsNode addChild:_newthing];
        lastblock = 100+(i+1)*newblock;
        if (arc4random()%4 == 0) {
            CCNode *th = [CCBReader load:@"JoeyThamanBolt"];
            th.position = ccp(100+(i+1)*newblock, 75+arc4random()%100+250);
            [_physicsNode addChild:th];
        }

    }
    // Create anything you'd like to draw here
}

-(void)update:(CCTime)delta {
    speed += delta;
    _followNode.physicsBody.velocity = ccp(speed, 0);
    
    int time_elapsed = CACurrentMediaTime()-starttime;

    if (time_elapsed > 60) {
        _label.string = @"0";
        [self endMinigameWithScore:100];
    } else {
        _label.string = [NSString stringWithFormat:@"%d",60-time_elapsed];
        
    }
    float xdif = _followNode.position.x-self.hero.position.x;
    if (xdif > width/2+200 || self.hero.position.x < -200) {
        [self endMinigameWithScore:round(_contentNode.position.x/6100)];
    }
    
    
    if ((_followNode.position.x-lastblock) > newblock-width-100) {
        CCSprite *_newthing = [CCBReader load:[NSString stringWithFormat:@"JoeyThamanIce%d", ((arc4random()%6)+1)]];
        _newthing.position = ccp(_followNode.position.x+width+100, 75+arc4random()%100);
        _newthing.scale = 3;
        [_physicsNode addChild:_newthing];
        lastblock = _followNode.position.x+width+100;
        if (arc4random()%4 == 0) {
            CCNode *th = [CCBReader load:@"JoeyThamanBolt"];
            th.position = ccp(_followNode.position.x+width+100, 75+arc4random()%100+250);
            [_physicsNode addChild:th];
        }
    }
        // Called each update cycle
    // n.b. Lag and other factors may cause it to be called more or less frequently on different devices or sessions
    // delta will tell you how much time has passed since the last cycle (in seconds)


    [self.hero updatev:MIN((_touch.position.x-_touchBox.position.x),160)];
    for (CCNode *_item in _enemies) {
        CGPoint thing;
        if (self.hero.position.x > _item.position.x) {
            thing = ccp(-50, 0);
        } else {
            thing = ccp(50, 0);
        }
        for (CCNode *_var in _item.children) {
            [_var.physicsBody applyForce:thing];
        }
    }
}

-(void)endMinigame {
    // Be sure you call this method when you end your minigame!
    // Of course you won't have a random score, but your score *must* be between 1 and 100 inclusive
    [self endMinigameWithScore:arc4random()%100 + 1];
}

// DO NOT DELETE!
-(MyCharacter *)hero {
    return (MyCharacter *)self.character;
}
// DO NOT DELETE!


- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInNode:self];
    _touch.position = touchLocation;
    _touchBox.position = _touch.position;
}



-(void) touchMoved:(UITouch*)touch withEvent:(UIEvent*)event {

        
    CGPoint touchLocation = [touch locationInNode:self];
    _touch.position = touchLocation;
    if (_touch.position.y < _touchBox.position.y) {
        _touchBox.position = ccp(_touchBox.position.x,_touch.position.y);
    }
    if ((_touch.position.y-_touchBox.position.y)>50) {
        [self.hero jump];
        _touchBox.position = ccp(_touchBox.position.x,_touch.position.y);
    }
    
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {

    
    _touchBox.position = ccp(0, 0);
    _touch.position = ccp(0, 0);
}

-(void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {

    _touchBox.position = ccp(0, 0);
    _touch.position = ccp(0, 0);
}

-(void) ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair her:(CCNode *)nodeA enemy:(CCNode *)nodeB {
    CCParticleSystem *explosion = [CCBReader load:@"JoeyThamanExplosion"];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the seals position
    explosion.position = ccp(nodeB.parent.position.x,nodeB.parent.position.y-64);
    // add the particle effect to the same node the seal is on
    [nodeB.parent.parent addChild:explosion];
    [nodeB.parent removeFromParent];
    [self.hero jump];
}

-(void) ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair her:(CCNode *)nodeA death:(CCNode *)nodeB {
    [self endMinigameWithScore:round(_contentNode.position.x/6100)];
}

-(void) ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair her:(CCNode *)nodeA block:(CCNode *)nodeB {
    [self.hero collide];
}

@end
