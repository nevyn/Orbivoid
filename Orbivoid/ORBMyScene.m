//
//  ORBMyScene.m
//  Orbivoid
//
//  Created by Joachim Bengtsson on 2013-08-27.
//  Copyright (c) 2013 Neto. All rights reserved.
//

#import "ORBMyScene.h"

@implementation ORBMyScene
{
    SKNode *_player;
    NSMutableArray *_enemies;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor blackColor];
        
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
        
        SKEmitterNode *background = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Background" ofType:@"sks"]];
            background.particlePositionRange = CGVectorMake(self.size.width*2, self.size.height*2);
        
        [self addChild:background];
        [self addChild:_player];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_player runAction:[SKAction moveTo:[[touches anyObject] locationInNode:self] duration:0.01]];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
