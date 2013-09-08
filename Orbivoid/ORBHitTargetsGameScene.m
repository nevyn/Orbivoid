//
//  ORBHitTargetsGameScene.m
//  Orbivoid
//
//  Created by Joachim Bengtsson on 2013-09-08.
//  Copyright (c) 2013 Neto. All rights reserved.
//

#import "ORBHitTargetsGameScene.h"
#import "ORBCharacterNode.h"
#import "SKEmitterNode+fromFile.h"

static float kSuspenseMultiplier = 10.;


enum {
    CollisionTarget = 1<<10,
};


@implementation ORBHitTargetsGameScene
{
    int _level;
    CGFloat _multiplier;
    NSTimeInterval _lastFrameTime;
    SKShapeNode *_multiplierIndicator;
}

- (id)initWithSize:(CGSize)size
{
    if(!(self = [super initWithSize:size]))
        return nil;
    
    self.scoreLabel.fontSize /= 2;

    
    _multiplier = 1;
    
    _multiplierIndicator = [SKShapeNode node];
        _multiplierIndicator.strokeColor = [SKColor clearColor];
        _multiplierIndicator.fillColor = [SKColor colorWithRed:0.6 green:0 blue:0 alpha:0.6];
        [self addChild:_multiplierIndicator];
    
    return self;
}

- (void)didMoveToView:(SKView *)view
{
    [self performSelector:@selector(levelUp) withObject:nil afterDelay:1.0];
}


-(void)levelUp;
{
	if(_level != 0) {
		[self runAction:[SKAction playSoundFileNamed:@"Levelup.wav" waitForCompletion:NO]];
		//[self blinkToColor:ColRGBA(0.5, 0.5, 1, 0.3)];
	}
	
	_level++;
		
	for(int i = 0; i < _level; i++) {
		//ORBCharacterNode *foo = [self randomOrb];
		//[self.layer addSublayer:foo];
        [self spawnEnemy];
	}
    
	if(_level == 1 || _level % 6 == 0) {
		[self spawnTarget];
    }
}

- (void)spawnTarget
{
    static const CGFloat squareSize = 40;
    SKNode *square = [SKNode new];
        SKShapeNode *shape = [SKShapeNode node];
            shape.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-squareSize/2, -squareSize/2, squareSize, squareSize) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)].CGPath;
            [square addChild:shape];
    
        square.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(squareSize, squareSize)];
        square.physicsBody.contactTestBitMask = CollisionEnemy;
        square.physicsBody.categoryBitMask = CollisionTarget;
        square.physicsBody.mass = 100000000;
    
        square.position = CGPointMake(arc4random_uniform(self.frame.size.width-80)+40, arc4random_uniform(self.frame.size.height-80)+40);
    
        [self addChild:square];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if(contact.bodyA.node == self.player) {
        [self dieFrom:contact.bodyB.node];
        contact.bodyB.node.physicsBody = nil;
        return;
    }
    // Else, it's a square -> enemy collision
    [self killEnemy:(id)contact.bodyB.node];
}

- (void)killEnemy:(ORBCharacterNode*)enemy
{
    self.score += MIN(_multiplier, kSuspenseMultiplier);
    _multiplier += 1.;
    
    [self.enemies removeObject:enemy];
    SKEmitterNode *explosion = [SKEmitterNode orb_emitterNamed:@"Explosion"];
    explosion.particleScale /= 2;
    explosion.particleLifetime /= 2;
    explosion.position = enemy.position;
    [self addChild:explosion];
    [explosion runAction:[SKAction playSoundFileNamed:@"SmallExplosion.wav" waitForCompletion:NO]];
    [explosion runAction:explosionAction(explosion, 0.2, ^{
        [enemy removeFromParent];
        [enemy didLeaveParent];
    }, ^{
        if(self.enemies.count == 0)
            [self levelUp];
    })];
}

- (void)update:(NSTimeInterval)currentTime
{
    [super update:currentTime];
    
    if(!_lastFrameTime)
        _lastFrameTime = currentTime;
    
    NSTimeInterval delta = currentTime - _lastFrameTime;

    _multiplier = MAX(1, _multiplier-delta);
    
    if( _multiplier >= kSuspenseMultiplier && ![self actionForKey:@"suspenseSound"]) {
        [self runAction:[SKAction repeatActionForever:[SKAction playSoundFileNamed:@"Suspense.wav" waitForCompletion:YES]] withKey:@"suspenseSound"];
    } else if(_multiplier < kSuspenseMultiplier && [self actionForKey:@"suspenseSound"]) {
        [self removeActionForKey:@"suspenseSound"];
    }
    
    _multiplierIndicator.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 50, self.frame.size.height * (_multiplier/kSuspenseMultiplier))].CGPath;
    
    _lastFrameTime = currentTime;
}


+ (NSString*)modeName
{
    return @"Target Practice";
}
@end
