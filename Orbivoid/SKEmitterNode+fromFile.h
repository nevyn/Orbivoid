//
//  SKEmitterNode+fromFile.h
//  Orbivoid
//
//  Created by Joachim Bengtsson on 2013-09-03.
//  Copyright (c) 2013 Neto. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKEmitterNode (fromFile)
+ (instancetype)orb_emitterNamed:(NSString*)name;
@end