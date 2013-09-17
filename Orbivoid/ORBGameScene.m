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


@interface ORBGameScene () <SKPhysicsContactDelegate>
@end

@implementation ORBGameScene
{
    NSMutableArray *_enemies;
    CGFloat _displayedScore;
    NSTimeInterval _currentTime;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor blackColor];
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        _enemies = [NSMutableArray new];
        
        SKEmitterNode *background = [SKEmitterNode orb_emitterNamed:@"Background"];
            background.particlePositionRange = CGVectorMake(self.size.width*2, self.size.height*2);
            [background advanceSimulationTime:10];
            [self addChild:background];
        
        _player = [[ORBCharacterNode alloc] initWithSize:CGSizeMake(10, 10)];
            _player.physicsBody.mass = 100000;
            _player.physicsBody.categoryBitMask = CollisionPlayer;
            _player.physicsBody.contactTestBitMask = CollisionEnemy;
            _player.position = CGPointMake(size.width/2, size.height/2);
            [self addChild:_player];
            [_player didMoveToParent];
        
        _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
            _scoreLabel.fontSize = 200;
            _scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
            _scoreLabel.fontColor = [SKColor colorWithHue:0 saturation:0 brightness:1 alpha:0.3];
            _scoreLabel.text = @"00";

            [self addChild:_scoreLabel];

    }
    return self;
}

- (void)didMoveToView:(SKView *)view
{
        [self runAction:[SKAction group:@[
/*            [SKAction spawnPlayer] => spawn animation, then add player to world,*/
        ]]];
}

- (ORBCharacterNode*)spawnEnemy
{
    if(_dead)
        return nil;
    
    ORBCharacterNode *enemy = [[ORBCharacterNode alloc] initWithSize:CGSizeMake(6, 6)];
        enemy.trail.particleColorSequence = [[SKKeyframeSequence alloc] initWithKeyframeValues:@[
            [SKColor redColor],
            [SKColor colorWithHue:0.1 saturation:.5 brightness:1 alpha:1],
            [SKColor redColor],
        ] times:@[@0, @0.02, @0.2]];
        enemy.trail.particleScale /= 2;
        enemy.position = [self randomEnemyPosition];
        enemy.physicsBody.categoryBitMask = CollisionEnemy;
        enemy.bornAt = _currentTime;
    
    [_enemies addObject:enemy];
    [self addChild:enemy];
    [enemy didMoveToParent];
    
    [self runAction:[SKAction playSoundFileNamed:@"Spawn.wav" waitForCompletion:NO]];
    
    return enemy;
}

- (CGPoint)randomEnemyPosition
{
    CGFloat radius = MAX(self.size.height, self.size.width)*0.7;
    CGFloat angle = (arc4random_uniform(1000)/1000.) * M_PI*2;
    CGPoint p = CGPointMake(cos(angle)*radius, sin(angle)*radius);
    return CGPointMake(self.size.width/2 + p.x, self.size.width/2 + p.y);
}

SKAction *explosionAction(SKEmitterNode *explosion, CGFloat duration, dispatch_block_t removal, dispatch_block_t afterwards)
{
    return [SKAction sequence:@[
		[SKAction waitForDuration:duration/2],
        [SKAction runBlock:removal],
		[SKAction waitForDuration:duration/2],
		[SKAction runBlock:^{
			explosion.particleBirthRate = 0;
		}],
		[SKAction waitForDuration:duration*2],
        [SKAction runBlock:afterwards],
    ]];
}

- (void)dieFrom:(SKNode*)killingEnemy
{
    _dead = YES;
    
    SKEmitterNode *explosion = [SKEmitterNode orb_emitterNamed:@"Explosion"];
    explosion.position = _player.position;
    [self addChild:explosion];
    [explosion runAction:[SKAction playSoundFileNamed:@"Explosion.wav" waitForCompletion:NO]];
    [explosion runAction:explosionAction(explosion, 0.8, ^{
        // TODO: Remove these more nicely
        [killingEnemy removeFromParent];
        [_player removeFromParent];
    }, ^{
        ORBMenuScene *menu = [[ORBMenuScene alloc] initWithSize:self.size];
        [self.view presentScene:menu transition:[SKTransition doorsCloseHorizontalWithDuration:0.5]];
    })];
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
    _currentTime = currentTime;
    CGPoint playerPos = _player.position;
    
    for(ORBCharacterNode *enemyNode in _enemies) {
        CGPoint enemyPos = enemyNode.position;
        
        /* Uniform speed: */
        CGVector diff = TCVectorMinus(playerPos, enemyPos);
        CGVector normalized = TCVectorUnit(diff);
        CGVector force = TCVectorMultiply(normalized, [enemyNode speedAtTime:currentTime]);
        
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
        [enemyNode pointToPlayer:_player];
    }
    
    _player.physicsBody.velocity = CGVectorMake(0, 0);
    
    if(self.score != _displayedScore) {
        self.scoreLabel.text = [NSString stringWithFormat:@"%02.0f", self.score];
        _displayedScore = self.score;
    }
}

+ (NSString*)modeName
{
    return @"Base class";
}
@end
