//
//  ORBTobiGameMode.m
//  Orbivoid
//
//  Created by Tobias Ahlin on 2013-09-17.
//  Copyright (c) 2013 Neto. All rights reserved.
//

#import "ORBTobiGameMode.h"
#import "ORBCharacterNode.h"

@implementation ORBTobiGameMode
- (CGPoint)randomEnemyPosition
{
    // Spawn next to the player
    CGPoint position = self.player.position;
    
    // Offset
    float maxOffset = 100;
//    float minOffset = 20;
    position.x += arc4random_uniform(maxOffset*2)-maxOffset;
    position.y += arc4random_uniform(maxOffset*2)-maxOffset;
    
    // Spawn within the frame
    position.x = MAX(0, position.x);
    position.x = MIN(self.frame.size.width, position.x);
    
    position.y = MAX(0, position.x);
    position.y = MIN(self.frame.size.width, position.x);
    
    return position;
}

- (id)initWithSize:(CGSize)size
{
    if(!(self = [super initWithSize:size]))
        return nil;
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    
    return self;
}

- (void)didMoveToView:(SKView *)view
{
    [self performSelector:@selector(spawnEnemy) withObject:nil afterDelay:1.0];
}

- (ORBCharacterNode*)spawnEnemy
{
    ORBCharacterNode *enemy = [super spawnEnemy];
    enemy.maxSpeed = 1.9;
    enemy.shouldPointToPlayer = NO;
    
    self.score += 1;
    
    // Next spawn
    CGFloat delay = MAX(2 - log10f(self.score+1), 0.2);
    NSLog(@"Delay: %f", delay);
    [self runAction:[SKAction sequence:@[
        [SKAction waitForDuration:delay],
        [SKAction performSelector:@selector(spawnEnemy) onTarget:self],
    ]]];
    
    return enemy;
}

+ (NSString*)modeName
{
    return @"Tobi's Mode";
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    [self dieFrom:contact.bodyB.node];
    contact.bodyB.node.physicsBody = nil;
}
@end
