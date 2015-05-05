//
//  HUPlayerTableViewController.m
//  PowerHour
//
//  Created by Hugey on 12/10/13.
//  Copyright (c) 2013 Hugey. All rights reserved.
//

/*
    Fix chime
    maybe fix how shuffle works - actionsheet
    make it pretty...
    pause inbetween songs (selectable)
 
 
 */


#import "HUPlayerTableViewController.h"
#import "HUSongObject.h"
#import <AudioToolbox/AudioServices.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <UIActionSheet+BlocksKit.h>
#import <NSArray+BlocksKit.h>

@interface HUPlayerTableViewController ()

    @property (nonatomic, strong) NSMutableArray *huSongArray;
    @property (nonatomic, strong) NSMutableArray *allSongsArray;
    @property (nonatomic, strong) NSTimer *tickerTimer;
    @property (nonatomic, assign) NSInteger songLength;
    @property (nonatomic, strong) NSDate *timeSongStarted;
    
    @property (nonatomic, assign) BOOL shouldRandomStart;
    @property (nonatomic, assign) BOOL shouldChime;

@end

@implementation HUPlayerTableViewController


-(void)viewWillDisappear:(BOOL)animated {
    [self.ipod stop];
    [self.tickerTimer invalidate];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = [self.playlist valueForProperty:MPMediaPlaylistPropertyName];
   
    self.shuffleAll = NO;
    self.shouldRandomStart = NO;
    self.shouldChime = NO;
    self.songLength = 60;
    
    self.songLengthLabel.text = [NSString stringWithFormat:@"%lu", (long)self.songLength];
    self.clockLabel.text = [NSString stringWithFormat:@"%lu", (long)self.songLength];
    self.slider.value = (CGFloat)self.songLength / 100.0;
    
    self.ipod = [MPMusicPlayerController systemMusicPlayer];
    [self.ipod pause];
    [self.ipod setShuffleMode:MPMusicShuffleModeOff];
    [self.ipod beginGeneratingPlaybackNotifications];

    
    // convert playlist to trimmed song objects
    self.huSongArray = [NSMutableArray array];
    NSArray *songs = self.playlist.items;
    for (MPMediaItem *song in songs) {
        HUSongObject *customSong = [[HUSongObject alloc] initWithSong:song shouldRandom:self.shouldRandomStart withMaxDuration:self.songLength];
        [self.huSongArray addObject:customSong];
    }
    self.allSongsArray = [self.huSongArray copy];
    
    
    [self reset];
}

- (void)reset {
    // convert playlist to trimmed song objects
    self.huSongArray = [NSMutableArray array];
    NSArray *songs = self.playlist.items;
    for (MPMediaItem *song in songs) {
        HUSongObject *customSong = [[HUSongObject alloc] init];
        customSong.song = song;
        [customSong calculateStartTime:self.shouldRandomStart withMaxDuration:self.songLength];
        [self.huSongArray addObject:customSong];
    }
    self.allSongsArray = [self.huSongArray copy];
    
    self.ipod = self.ipod = [MPMusicPlayerController systemMusicPlayer];
    [self.ipod stop];
    [self.ipod setShuffleMode:MPMusicShuffleModeOff];
    [self.ipod beginGeneratingPlaybackNotifications];
}

- (void)play {
    self.tickerTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tickerTimerFired) userInfo:nil repeats:YES];
    self.timeSongStarted = [NSDate date];
    
    HUSongObject *s = self.huSongArray[0];
    [self.ipod setNowPlayingItem:s.song];
    [self.ipod setCurrentPlaybackTime:s.start];
    
    [self.ipod play];
}

- (void)shuffle {
    NSInteger startIndex = 0;
    if (self.shuffleAll) {
        startIndex = 1;
    }
}

- (void)nextSong {
    [self.ipod pause];
    [self.tickerTimer invalidate];
    
    // play delay before actually playing song.
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.playbackGap * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        if (self.huSongArray.count > 0) {
            [self play];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Finished" message:@"Playlist is out of songs. Faded yet?" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
        }
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(MPMediaItemCollection*)playlistFromHUSongArray {
    NSMutableArray *songItemArray = [NSMutableArray array];
    for (HUSongObject *s in self.huSongArray) {
        [songItemArray addObject:s.song];
    }
    
    MPMediaItemCollection *list = [MPMediaPlaylist collectionWithItems:songItemArray];
    return list;
}

/*
-(void)nextSong {
    [self.ipod pause];
    
    if (self.shouldChime) {
        AudioServicesPlaySystemSound(1023);
    }
    
    if ([self.huSongArray count] <= 1) {
        [self.tickerTimer invalidate];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Finished" message:@"Playlist is out of songs. Faded yet?" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        return;
    }

    [self.huSongArray removeObjectAtIndex:0];
    [self.ipod setQueueWithItemCollection:[self playlistFromHUSongArray]];

    HUSongObject *song = self.huSongArray[0];
    
    [self.ipod setNowPlayingItem:song.song];
    [self.ipod setCurrentPlaybackTime:song.start];
    [self.ipod play];
    [self.tableView reloadData];
    self.timeSongStarted = [NSDate date];
}
 */

-(void)tickerTimerFired {
    NSTimeInterval songInterval = -1.0 * [self.timeSongStarted timeIntervalSinceNow];
    
    int difference = self.songLength - songInterval;
    difference = difference > 0 ? difference : 0;
    self.clockLabel.text = [NSString stringWithFormat:@"%d", difference];
    if (difference <= 0) {
        [self nextSong];
    }
}

#pragma mark - UIAlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.huSongArray.count > 0) {
        return self.huSongArray.count - 1;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SongCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UILabel *nameLabel = (UILabel*)[cell viewWithTag:21];
    UILabel *artistLabel = (UILabel*)[cell viewWithTag:22];
    UILabel *nowPlayingLabel = (UILabel*)[cell viewWithTag:23];

    MPMediaItem *item = [self.huSongArray[indexPath.row] song];
    
    nameLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    
    artistLabel.text = [item valueForProperty:MPMediaItemPropertyArtist];
    artistLabel.textAlignment = NSTextAlignmentLeft;
    
    nowPlayingLabel.hidden = YES;
    
    if (indexPath.row == 0) {
        nowPlayingLabel.hidden = NO;
        nameLabel.textAlignment = NSTextAlignmentRight;
        artistLabel.textAlignment = NSTextAlignmentRight;
    }
    
    return cell;
}

#pragma mark - MPMusicPlayerController Notifications


- (IBAction)shuffleButtonPressed:(id)sender {
    UIActionSheet* sheet = [[UIActionSheet alloc] bk_initWithTitle:@"Shuffle"];
    
    
   
    /*
    if (self.shuffleAll) {
        [self reset];
    }
    
    NSUInteger count = [self.huSongArray count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger nElements = count - i;
        NSInteger n = arc4random_uniform((UInt32)nElements) + i;
        if (!self.shuffleAll && self.ipod.playbackState == MPMusicPlaybackStatePlaying && (i == 0 || n == 0)) {
            // dont shuffle the first song if it is playing
            continue;
        }
        [self.huSongArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
     */
    
    [self.tableView reloadData];
}

- (IBAction)playButtonPressed:(id)sender {
    switch (self.ipod.playbackState) {
        case MPMusicPlaybackStatePlaying: {
            [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
            [self.ipod pause];
    
            [self.tickerTimer invalidate];
            
            break;
        }
        case MPMusicPlaybackStatePaused:
        case MPMusicPlaybackStateStopped:
        case MPMusicPlaybackStateInterrupted: {
            [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
            
            [self play];
            
            
            self.timeSongStarted = [NSDate date];
            
            HUSongObject *s = self.huSongArray[0];
            [self.ipod setCurrentPlaybackTime:s.start];
            [self.ipod play];
            
            self.tickerTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tickerTimerFired) userInfo:nil repeats:YES];

            break;
        }
        default:
            break;
    }
}

- (IBAction)chimeSwitchValueChanged:(id)sender {
    UISwitch *sw = (UISwitch*)sender;
    self.shouldChime = sw.isOn;
}

- (IBAction)randomStartButtonPressed:(id)sender {
    UIButton *button = (UIButton*)sender;
   
    @weakify(self)
    void (^shuffleBlock)(void) = ^void(void){
        @strongify(self)
        for (HUSongObject *s in self.huSongArray) {
            [s calculateStartTime:self.shouldRandomStart withMaxDuration:self.songLength];
        }
    };
    
    UIActionSheet* sheet = [[UIActionSheet alloc] bk_initWithTitle:@"Random Song Beginnings"];
    [sheet bk_addButtonWithTitle:@"Off" handler:^{
        @strongify(self)
        self.shouldRandomStart = NO;
        [button setTitle:@"Random Start: OFF" forState:UIControlStateNormal];
    }];
    [sheet bk_addButtonWithTitle:@"On - Future Songs" handler:^{
        @strongify(self)
        self.shouldRandomStart = YES;
        [button setTitle:@"Random Start: ON" forState:UIControlStateNormal];
        
        shuffleBlock();
    }];
    [sheet bk_addButtonWithTitle:@"On - Reset Current Song" handler:^{
        @strongify(self)
        self.shouldRandomStart = YES;
        [button setTitle:@"Random Start: ON" forState:UIControlStateNormal];
        
        MPMediaItem* currentItem = self.ipod.nowPlayingItem;
        if (currentItem) {
            HUSongObject* s = [self.allSongsArray bk_match:^BOOL(HUSongObject* obj) {
                return obj.song.persistentID == currentItem.persistentID;
            }];
            if (s) {
                [s calculateStartTime:self.shouldRandomStart withMaxDuration:self.songLength];
                [self.huSongArray insertObject:s atIndex:0];
                [self nextSong];
            }
        }
        shuffleBlock();
    }];
    
    [sheet showInView:self.view];
}

- (IBAction)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider*)sender;
    self.songLength = slider.value * 75;
    self.songLengthLabel.text = [NSString stringWithFormat:@"%lu", (long)self.songLength];
}

@end
