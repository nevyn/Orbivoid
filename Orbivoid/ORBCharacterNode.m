//
//  ORBCharacterNode.m
//  Orbivoid
//
//  Created by Joachim Bengtsson on 2013-09-03.
//  Copyright (c) 2013 Neto. All rights reserved.
//

#import "ORBCharacterNode.h"
#import "SKEmitterNode+fromFile.h"

@implementation ORBCharacterNode
- (id)initWithSize:(CGSize)size
{
    if(!(self = [super init]))
        return nil;
    
    _trail = [SKEmitterNode orb_emitterNamed:@"Trail"];
        _trail.position = CGPointMake(size.width/2, size.height/2);
        [self addChild:_trail];

    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:size.width];
    self.physicsBody.allowsRotation = NO;
    
    return self;
}
- (void)didMoveToParent
{
    _trail.targetNode = self.parent;
}
@end
