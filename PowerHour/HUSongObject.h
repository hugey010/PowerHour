//
//  HUSongObject.h
//  PowerHour
//
//  Created by Hugey on 12/10/13.
//  Copyright (c) 2013 Hugey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface HUSongObject : NSObject

@property (nonatomic, assign) NSTimeInterval length;
@property (nonatomic, assign) NSTimeInterval start;
@property (nonatomic, strong) MPMediaItem *song;

- (instancetype)initWithSong:(MPMediaItem*)song shouldRandom:(BOOL)random withMaxDuration:(CGFloat)duration NS_DESIGNATED_INITIALIZER;
- (void)calculateStartTime:(BOOL)shouldRandom withMaxDuration:(CGFloat)duration;

@end
