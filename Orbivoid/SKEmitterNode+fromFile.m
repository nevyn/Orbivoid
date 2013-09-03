//
//  SKEmitterNode+fromFile.m
//  Orbivoid
//
//  Created by Joachim Bengtsson on 2013-09-03.
//  Copyright (c) 2013 Neto. All rights reserved.
//

#import "SKEmitterNode+fromFile.h"

@implementation SKEmitterNode (fromFile)
+ (instancetype)orb_emitterNamed:(NSString*)name
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:name ofType:@"sks"]];
}
@end

