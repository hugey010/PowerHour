//
//  HUPlayerTableViewController.h
//  PowerHour
//
//  Created by Hugey on 12/10/13.
//  Copyright (c) 2013 Hugey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface HUPlayerTableViewController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic, assign) CGFloat playbackGap;

@property (nonatomic, strong) MPMediaPlaylist *playlist;
@property (nonatomic, strong) MPMusicPlayerController *ipod;

@property (weak, nonatomic) IBOutlet UILabel *clockLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *songLengthLabel;
@property (weak, nonatomic) IBOutlet UIView *volumeView;
@property (weak, nonatomic) IBOutlet UISlider *slider;

- (IBAction)shuffleButtonPressed:(id)sender;
- (IBAction)playButtonPressed:(id)sender;
- (IBAction)chimeSwitchValueChanged:(id)sender;
- (IBAction)sliderValueChanged:(id)sender;
- (IBAction)randomStartButtonPressed:(id)sender;

// for the app delegate to know to use background tasks or not
+ (BOOL)isCurrentlyPlaying;
+ (NSTimeInterval)songInterval;
+ (NSTimeInterval)timeLeftForCurrentSong;
+ (NSInteger)numberOfSongsLeft;

@end
