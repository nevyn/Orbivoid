//
//  ORBMyScene.h
//  Orbivoid
//

//  Copyright (c) 2013 Neto. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class ORBCharacterNode;

enum {
    CollisionPlayer = 1<<1,
    CollisionEnemy = 1<<2,
};

@interface ORBGameScene : SKScene
@property(nonatomic,readonly) SKLabelNode *scoreLabel;
@property(nonatomic,readonly) NSMutableArray *enemies;
@property(nonatomic,readonly) ORBCharacterNode *player;
@property(nonatomic,readonly) BOOL dead;
@property(nonatomic) CGFloat score;
+ (NSString*)modeName;

- (void)dieFrom:(SKNode*)killingEnemy;
- (ORBCharacterNode*)spawnEnemy;
- (CGPoint)randomEnemyPosition;
@end

SKAction *explosionAction(SKEmitterNode *explosion, CGFloat duration, dispatch_block_t removal, dispatch_block_t afterwards);