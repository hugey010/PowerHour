//
//  HUPlayerTableViewController.m
//  PowerHour
//
//  Created by Hugey on 12/10/13.
//  Copyright (c) 2013 Hugey. All rights reserved.
//

#import "HUPlayerTableViewController.h"
#import "HUSongObject.h"
#import <AudioToolbox/AudioServices.h>

@interface HUPlayerTableViewController () {
    NSMutableArray *huSongArray;
    
    NSTimer *tickerTimer;
    int songLength;
    NSDate *timeSongStarted;
    
    BOOL justShuffled;
    
    BOOL shouldRandomStart;
    BOOL shouldChime;
}

@end

@implementation HUPlayerTableViewController


-(void)viewWillDisappear:(BOOL)animated {
    [self.ipod stop];
    [tickerTimer invalidate];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = [self.playlist valueForProperty:MPMediaPlaylistPropertyName];
    
    justShuffled = NO;
    shouldRandomStart = NO;
    shouldChime = NO;
    songLength = 60;
    
    self.songLengthLabel.text = [NSString stringWithFormat:@"%d", songLength];
    self.clockLabel.text = [NSString stringWithFormat:@"%d", songLength];
    self.slider.value = (float)songLength / 100.0;
    
    self.ipod = [MPMusicPlayerController iPodMusicPlayer];
    [self.ipod pause];
    [self.ipod setShuffleMode:MPMusicShuffleModeOff];

    
    // convert playlist to trimmed song objects
    huSongArray = [NSMutableArray array];
    NSArray *songs = self.playlist.items;
    for (MPMediaItem *song in songs) {
        
        HUSongObject *customSong = [[HUSongObject alloc] init];
        customSong.song = song;
        customSong.start = 0.0;
        [huSongArray addObject:customSong];
    }
    
    [self.ipod setQueueWithItemCollection:[self playlistFromHUSongArray]];
}

-(MPMediaItemCollection*)playlistFromHUSongArray {
    NSMutableArray *songItemArray = [NSMutableArray array];
    for (HUSongObject *s in huSongArray) {
        [songItemArray addObject:s.song];
    }
    MPMediaItemCollection *list = [MPMediaPlaylist collectionWithItems:songItemArray];
    return list;
}

-(void)nextSong {
    [self.ipod pause];
    
    if (shouldChime) {
        AudioServicesPlaySystemSound(1023);
    }
    
    if ([huSongArray count] <= 1) {
        [tickerTimer invalidate];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Finished" message:@"Playlist is out of songs. Faded yet?" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        return;
    }

    [huSongArray removeObjectAtIndex:0];
    [self.ipod setQueueWithItemCollection:[self playlistFromHUSongArray]];

    HUSongObject *song = huSongArray[0];
    
    [self.ipod setNowPlayingItem:song.song];
    [self.ipod setCurrentPlaybackTime:song.start];
    [self.ipod play];
    [self.tableView reloadData];
    timeSongStarted = [NSDate date];
}

-(void)tickerTimerFired {
    
    NSTimeInterval songInterval = -1.0 * [timeSongStarted timeIntervalSinceNow];
    
    int difference = songLength - songInterval;
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
    return [huSongArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SongCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    MPMediaItem *item = [huSongArray[indexPath.row] song];
    
    UILabel *nameLabel = (UILabel*)[cell viewWithTag:21];
    UILabel *artistLabel = (UILabel*)[cell viewWithTag:22];
    
    nameLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];
    artistLabel.text = [item valueForProperty:MPMediaItemPropertyArtist];
    
    if (indexPath.row == 0) {
        [cell setTintColor:[UIColor greenColor]];
    }
    
    return cell;
}

- (IBAction)shuffleButtonPressed:(id)sender {
    justShuffled = YES;
    
    NSUInteger count = [huSongArray count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger nElements = count - i;
        NSInteger n = arc4random_uniform(nElements) + i;
        if (self.ipod.playbackState == MPMusicPlaybackStatePlaying && (i == 0 || n == 0)) {
            // dont shuffle the first song if it is playing
            continue;
        }
        [huSongArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    [self.tableView reloadData];
}

- (IBAction)playButtonPressed:(id)sender {
    
    switch (self.ipod.playbackState) {
        case MPMusicPlaybackStatePlaying: {
            [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
            [self.ipod pause];
    
            [tickerTimer invalidate];
            

            break;
        }
        case MPMusicPlaybackStatePaused:
        case MPMusicPlaybackStateStopped:
        case MPMusicPlaybackStateInterrupted: {
            [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
            
            if (justShuffled) {
                justShuffled = NO;
                [self.ipod setQueueWithItemCollection:[self playlistFromHUSongArray]];
            }
            
            if (self.ipod.playbackState != MPMusicPlaybackStatePaused) {
                timeSongStarted = [NSDate date];
            }
            
            HUSongObject *s = huSongArray[0];
            [self.ipod setCurrentPlaybackTime:s.start];
            [self.ipod play];
            
            tickerTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tickerTimerFired) userInfo:nil repeats:YES];

            break;
        }
        default:
            break;
    }
}

- (IBAction)chimeSwitchValueChanged:(id)sender {
    UISwitch *sw = (UISwitch*)sender;
    shouldChime = sw.isOn;
}

- (IBAction)randomStartSwitchValueChanged:(id)sender {
    UISwitch *sw = (UISwitch*)sender;
    shouldRandomStart = sw.isOn;
    
    for (HUSongObject *s in huSongArray) {
        if (shouldRandomStart) {
            NSTimeInterval length = [[s.song valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
            if (length <= songLength) {
                s.start = 0;
            } else {
                NSTimeInterval randomStart = arc4random() % (int)(length - songLength);
                s.start = randomStart;
            }
        } else {
            s.start = 0;
        }
    }
}

- (IBAction)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider*)sender;
    songLength = slider.value * 75;
    self.songLengthLabel.text = [NSString stringWithFormat:@"%d", songLength];
}

@end
