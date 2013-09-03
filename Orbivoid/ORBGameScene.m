//
//  ORBMyScene.m
//  Orbivoid
//
//  Created by Joachim Bengtsson on 2013-08-27.
//  Copyright (c) 2013 Neto. All rights reserved.
//

#import "ORBGameScene.h"
#import "ORBMenuScene.h"
#import "CGVector+TC.h"
#import "SKEmitterNode+fromFile.h"
#import "ORBCharacterNode.h"

enum {
    CollisionPlayer = 1<<1,
    CollisionEnemy = 1<<2,
};


@interface ORBGameScene () <SKPhysicsContactDelegate>
@end

@implementation ORBGameScene
{
    ORBCharacterNode *_player;
    NSMutableArray *_enemies;
    BOOL _dead;
    SKLabelNode *_scoreLabel;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor blackColor];
        
        self.physicsWorld.gravity = CGPointMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        _enemies = [NSMutableArray new];
        
        _player = [[ORBCharacterNode alloc] initWithSize:CGSizeMake(10, 10) spawningParticlesIn:self];
            _player.physicsBody.mass = 100000;
            _player.physicsBody.categoryBitMask = CollisionPlayer;
            _player.physicsBody.contactTestBitMask = CollisionEnemy;
            _player.position = CGPointMake(size.width/2, size.height/2);
        
        SKEmitterNode *background = [SKEmitterNode orb_emitterNamed:@"Background"];
            background.particlePositionRange = CGVectorMake(self.size.width*2, self.size.height*2);
            [background advanceSimulationTime:10];
        
        [self addChild:background];
        [self addChild:_player];
        
        [self updateScoreLabel];
    }
    return self;
}

- (void)didMoveToView:(SKView *)view
{
        [self runAction:[SKAction group:@[
/*            [SKAction spawnPlayer] => spawn animation, then add player to world,*/
        ]]];
    [self performSelector:@selector(spawnEnemy) withObject:nil afterDelay:1.0];
}

- (void)spawnEnemy
{
    if(_dead)
        return;
    
    ORBCharacterNode *enemy = [[ORBCharacterNode alloc] initWithSize:CGSizeMake(6, 6) spawningParticlesIn:self];
        enemy.trail.particleColorSequence = [[SKKeyframeSequence alloc] initWithKeyframeValues:@[
            [SKColor redColor],
            [SKColor colorWithHue:0.1 saturation:.5 brightness:1 alpha:1],
            [SKColor redColor],
        ] times:@[@0, @0.02, @0.2]];
        enemy.trail.particleScale /= 2;
        CGFloat radius = MAX(self.size.height, self.size.width)*0.7;
        CGFloat angle = (arc4random_uniform(1000)/1000.) * M_PI*2;
        CGPoint p = CGPointMake(cos(angle)*radius, sin(angle)*radius);
        enemy.position = CGPointMake(self.size.width/2 + p.x, self.size.width/2 + p.y);
        enemy.physicsBody.categoryBitMask = CollisionEnemy;
    
    [_enemies addObject:enemy];
    [self addChild:enemy];
    [self updateScoreLabel];
    
    [self runAction:[SKAction playSoundFileNamed:@"Spawn.wav" waitForCompletion:NO]];
    
    // Next spawn
    [self runAction:[SKAction sequence:@[
        [SKAction waitForDuration:5],
        [SKAction performSelector:@selector(spawnEnemy) onTarget:self],
    ]]];
}

- (void)updateScoreLabel
{
    if(!_scoreLabel) {
        _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
        
        _scoreLabel.fontSize = 200;
        _scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        _scoreLabel.fontColor = [SKColor colorWithHue:0 saturation:0 brightness:1 alpha:0.3];
        [self addChild:_scoreLabel];
    }
    _scoreLabel.text = [NSString stringWithFormat:@"%02d", _enemies.count];
}

- (void)dieFrom:(SKNode*)killingEnemy
{
    _dead = YES;
    
    SKEmitterNode *explosion = [SKEmitterNode orb_emitterNamed:@"Explosion"];
    explosion.position = _player.position;
    [self addChild:explosion];
    [explosion runAction:[SKAction sequence:@[
        [SKAction playSoundFileNamed:@"Explosion.wav" waitForCompletion:NO],
		[SKAction waitForDuration:0.4],
        [SKAction runBlock:^{
            // TODO: Remove these more nicely
            [killingEnemy removeFromParent];
            [_player removeFromParent];
        }],
		[SKAction waitForDuration:0.4],
		[SKAction runBlock:^{
			explosion.particleBirthRate = 0;
		}],
		[SKAction waitForDuration:1.2],
        
        [SKAction runBlock:^{
            ORBMenuScene *menu = [[ORBMenuScene alloc] initWithSize:self.size];
            [self.view presentScene:menu transition:[SKTransition doorsCloseHorizontalWithDuration:0.5]];
        }],
	]]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_dead)
        return;
    
    [_player runAction:[SKAction moveTo:[[touches anyObject] locationInNode:self] duration:0.01]];
}

-(void)update:(CFTimeInterval)currentTime
{
    
    CGPoint playerPos = _player.position;
    
    for(SKNode *enemyNode in _enemies) {
        CGPoint enemyPos = enemyNode.position;
        
        /* Uniform speed: */
        CGVector diff = TCVectorMinus(playerPos, enemyPos);
        CGVector normalized = TCVectorUnit(diff);
        CGVector force = TCVectorMultiply(normalized, 4);
        
        /* Inversely proportional:
        CGVector diff = TCVectorMinus(playerPos, enemyPos);
        CGVector normalized = TCVectorUnit(diff);
        CGVector force = TCVectorMultiply(normalized, 1/sqrt(TCVectorLength(diff))*40);
        */
        
        /* Inverse square root
        CGVector diff = TCVectorMinus(playerPos, enemyPos);
        CGVector normalized = TCVectorUnit(diff);
        CGVector force = TCVectorMultiply(normalized, 1/sqrt(TCVectorLength(diff))*40);
        */
        
        [enemyNode.physicsBody applyForce:force];
    }
    
    _player.physicsBody.velocity = CGVectorMake(0, 0);
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if(_dead)
        return;
    
    [self dieFrom:contact.bodyB.node];
    contact.bodyB.node.physicsBody = nil;
}

@end
