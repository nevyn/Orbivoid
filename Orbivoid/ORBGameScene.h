//
//  ORBMyScene.h
//  Orbivoid
//

//  Copyright (c) 2013 Neto. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class ORBCharacterNode;

@interface ORBGameScene : SKScene
@property(nonatomic,readonly) SKLabelNode *scoreLabel;
@property(nonatomic,readonly) NSMutableArray *enemies;
@property(nonatomic,readonly) ORBCharacterNode *player;
@property(nonatomic,readonly) BOOL dead;
@property(nonatomic) CGFloat score;
+ (NSString*)modeName;

- (void)dieFrom:(SKNode*)killingEnemy;
- (void)spawnEnemy;
@end