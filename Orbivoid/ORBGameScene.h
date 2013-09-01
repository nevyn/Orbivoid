//
//  ORBMyScene.h
//  Orbivoid
//

//  Copyright (c) 2013 Neto. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ORBGameScene : SKScene

@end


@interface SKEmitterNode (fromFile)
+ (instancetype)orb_emitterNamed:(NSString*)name;
@end