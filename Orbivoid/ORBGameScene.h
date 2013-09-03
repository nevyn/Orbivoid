//
//  ORBMyScene.h
//  Orbivoid
//

//  Copyright (c) 2013 Neto. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ORBGameScene : SKScene
@property(nonatomic,readonly) SKLabelNode *scoreLabel;
@property(nonatomic,readonly) NSMutableArray *enemies;
+ (NSString*)modeName;

- (void)dieFrom:(SKNode*)killingEnemy;
- (void)spawnEnemy;
- (void)updateScoreLabel;
@end