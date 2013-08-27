//
//  ORBMyScene.m
//  Orbivoid
//
//  Created by Joachim Bengtsson on 2013-08-27.
//  Copyright (c) 2013 Neto. All rights reserved.
//

#import "ORBGameScene.h"
#import "CGVector+TC.h"

@implementation ORBGameScene
{
    SKNode *_player;
    NSMutableArray *_enemies;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor blackColor];
        
        self.physicsWorld.gravity = CGPointMake(0, 0);
        _enemies = [NSMutableArray new];
        
        _player = [SKNode node];
            SKShapeNode *circle = [SKShapeNode node];
            circle.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 20, 20)].CGPath;
            circle.fillColor = [UIColor blueColor];
            circle.strokeColor = [UIColor blueColor];
            circle.glowWidth = 5;
        
            SKEmitterNode *smoke = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Trail" ofType:@"sks"]];
            smoke.targetNode = self;
            smoke.position = CGPointMake(CGRectGetMidX(circle.frame), CGRectGetMidY(circle.frame));
            [_player addChild:smoke];
        
            _player.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:20];
            _player.physicsBody.mass = 100000;
        
        SKEmitterNode *background = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Background" ofType:@"sks"]];
            background.particlePositionRange = CGVectorMake(self.size.width*2, self.size.height*2);
        
        [self addChild:background];
        [self addChild:_player];
        
        [self runAction:[SKAction group:@[
            [SKAction waitForDuration:1.0],
            [SKAction performSelector:@selector(spawnEnemy) onTarget:self]
        ]]];
    }
    return self;
}

- (void)spawnEnemy
{
    [SKAction playSoundFileNamed:@"Spawn.wav" waitForCompletion:NO];
    
    SKNode *enemy = [SKNode node];
    
        SKEmitterNode *smoke = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Trail" ofType:@"sks"]];
        smoke.targetNode = self;
        smoke.particleColor = [UIColor redColor];
        smoke.position = CGPointMake(10, 10);
        [enemy addChild:smoke];
        enemy.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:20];
        enemy.position = CGPointMake(100, 100);
    
    [_enemies addObject:enemy];
    [self addChild:enemy];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_player runAction:[SKAction moveTo:[[touches anyObject] locationInNode:self] duration:0.01]];
}

-(void)update:(CFTimeInterval)currentTime
{
    
    CGPoint playerPos = _player.position;
    
    for(SKNode *enemyNode in _enemies) {
        CGPoint enemyPos = enemyNode.position;
        CGVector diff = TCVectorMinus(playerPos, enemyPos);
        CGVector unit = TCVectorUnit(diff);
        CGVector force = TCVectorMultiply(unit, 100);
        
        [enemyNode.physicsBody applyForce:force];
    }
    
    _player.physicsBody.velocity = CGVectorMake(0, 0);
}

@end
