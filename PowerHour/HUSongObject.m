//
//  HUSongObject.m
//  PowerHour
//
//  Created by Hugey on 12/10/13.
//  Copyright (c) 2013 Hugey. All rights reserved.
//

#import "HUSongObject.h"

@implementation HUSongObject

- (instancetype)initWithSong:(MPMediaItem*)song shouldRandom:(BOOL)random withMaxDuration:(CGFloat)duration {
    self = [super init];
    if (!self) { return nil; }
    
    self.song = song;
    [self calculateStartTime:random withMaxDuration:duration];
    
    return self;
}


- (void)calculateStartTime:(BOOL)random withMaxDuration:(CGFloat)duration {
    if (random) {
        NSTimeInterval length = [[self.song valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
        if (length <= duration) {
            self.start = 0.0;
        } else {
            NSTimeInterval randomStart = arc4random() % (int)(length - duration);
            self.start = randomStart;
        }
    } else {
        self.start = 0.0;
    }
}

@end
