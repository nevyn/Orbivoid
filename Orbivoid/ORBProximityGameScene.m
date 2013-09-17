//
//  ORBProximityGameScene.m
//  Orbivoid
//
//  Created by Joachim Bengtsson on 2013-09-08.
//  Copyright (c) 2013 Neto. All rights reserved.
//

#import "ORBProximityGameScene.h"
#import "ORBCharacterNode.h"
#import "CGVector+TC.h"

@implementation ORBProximityGameScene
{
    NSTimeInterval _lastScoringTime;
}
- (id)initWithSize:(CGSize)size
{
    if(!(self = [super initWithSize:size]))
        return nil;
    
    self.scoreLabel.fontSize /= 2;
    
    return self;
}

- (void)didMoveToView:(SKView *)view
{
    [self performSelector:@selector(spawnEnemy) withObject:nil afterDelay:1.0];
}

- (ORBCharacterNode*)spawnEnemy
{
    id enemy = [super spawnEnemy];
    
    // Next spawn
    [self runAction:[SKAction sequence:@[
        [SKAction waitForDuration:10],
        [SKAction performSelector:@selector(spawnEnemy) onTarget:self],
    ]]];
    
    return enemy;
}

- (void)update:(NSTimeInterval)currentTime
{
    [super update:currentTime];
    if(self.dead)
        return;
    
    if(!_lastScoringTime)
        _lastScoringTime = currentTime;
    
    CGFloat delta = currentTime - _lastScoringTime;
    
    CGPoint playerPos = self.player.position;
    
    for(ORBCharacterNode *enemyNode in self.enemies) {
        CGPoint enemyPos = enemyNode.position;
        
        CGVector diff = TCVectorMinus(playerPos, enemyPos);
        CGFloat dist = TCVectorLength(diff);
        
        if(dist > 200)
            continue;
        
        CGFloat scorePerSec = MIN(20, 300/dist);
        
        self.score += scorePerSec * delta;
    }
    
    _lastScoringTime = currentTime;
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    [self dieFrom:contact.bodyB.node];
    contact.bodyB.node.physicsBody = nil;
}


+ (NSString*)modeName
{
    return @"Proximity";
}

@end
