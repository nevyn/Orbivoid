//
//  ORBAvoidGameScene.m
//  Orbivoid
//
//  Created by Joachim Bengtsson on 2013-09-03.
//  Copyright (c) 2013 Neto. All rights reserved.
//

#import "ORBAvoidGameScene.h"

@implementation ORBAvoidGameScene

- (void)didMoveToView:(SKView *)view
{
    [self performSelector:@selector(spawnEnemy) withObject:nil afterDelay:1.0];
}

- (ORBCharacterNode*)spawnEnemy
{
    id enemy = [super spawnEnemy];
    self.score += 1;
    
    // Next spawn
    [self runAction:[SKAction sequence:@[
        [SKAction waitForDuration:5],
        [SKAction performSelector:@selector(spawnEnemy) onTarget:self],
    ]]];
    
    return enemy;
}

+ (NSString*)modeName
{
    return @"Avoid Orbs";
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    [self dieFrom:contact.bodyB.node];
    contact.bodyB.node.physicsBody = nil;
}
@end
