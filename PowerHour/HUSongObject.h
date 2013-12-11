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

@end
