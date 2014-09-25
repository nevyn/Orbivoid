//
//  SKEmitterNode+ORBFileLoading.m
//  Orbivoid
//
//  Created by Joachim Bengtsson on 2014-09-25.
//  Copyright (c) 2014 Neto. All rights reserved.
//

#import "SKEmitterNode+ORBFileLoading.h"

@implementation SKEmitterNode (fromFile)
+ (instancetype)orb_emitterNamed:(NSString*)name
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:name ofType:@"sks"]];
}
@end

