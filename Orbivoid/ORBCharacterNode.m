#import "ORBCharacterNode.h"
#import "SKEmitterNode+fromFile.h"
#import "CGVector+TC.h"

@implementation ORBCharacterNode
{
    SKShapeNode *_line;
}
- (id)initWithSize:(CGSize)size
{
    if(!(self = [super init]))
        return nil;
    
    _size = size;
    _trail = [SKEmitterNode orb_emitterNamed:@"Trail"];
        _trail.position = CGPointMake(size.width/2, size.height/2);
        [self addChild:_trail];

    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:size.width];
    self.physicsBody.allowsRotation = NO;
    
    _maxSpeed = 4;
    
    return self;
}

- (CGFloat)speedAtTime:(NSTimeInterval)time
{
    static const CGFloat accelerationTime = 2;
    return self.maxSpeed * MIN(1, (time - _bornAt)/accelerationTime);
}

- (void)didMoveToParent
{
    _trail.targetNode = self.parent;
}
- (void)didLeaveParent;
{
    [_line removeFromParent];
}

- (void)pointToPlayer:(ORBCharacterNode*)player;
{
    if(!_shouldPointToPlayer)
        return;
    
    if(!player.parent) {
        _line.alpha = 0;
        return;
    }
    
    if(!_line) {
        _line = [SKShapeNode node];
        _line.strokeColor = [SKColor colorWithWhite:1 alpha:.5];
        _line.lineWidth = 1;
        _line.glowWidth = 3;
    }
    [self.parent insertChild:_line atIndex:0];
    UIBezierPath *bzp = [UIBezierPath bezierPath];
    
    CGPoint source = self.position;
    source.x += self.size.width/2; source.y += self.size.height/2;
    CGPoint target = player.position;
    target.x += player.size.width/2; target.y += player.size.height/2;
    
    CGVector diff = TCVectorMinus(source, target);
    
    static const float alphaDistance = 1000;
    _line.alpha = MAX(0, (alphaDistance - TCVectorLength(diff))/alphaDistance);
    
    [bzp moveToPoint:source];
    [bzp addLineToPoint:target];
    _line.path = bzp.CGPath;
}
@end
