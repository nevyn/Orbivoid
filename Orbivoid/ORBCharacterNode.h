//
//  ORBCharacterNode.h
//  Orbivoid
//
//  Created by Joachim Bengtsson on 2013-09-03.
//  Copyright (c) 2013 Neto. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ORBCharacterNode : SKNode
@property(nonatomic,readonly) SKEmitterNode *trail;
@property(nonatomic,readonly) CGSize size;
- (id)initWithSize:(CGSize)size;
- (void)didMoveToParent;
- (void)didLeaveParent;
- (void)pointToPlayer:(ORBCharacterNode*)player;
@end
