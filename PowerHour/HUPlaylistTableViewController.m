//
//  HUPlaylistTableViewController.m
//  PowerHour
//
//  Created by Hugey on 12/10/13.
//  Copyright (c) 2013 Hugey. All rights reserved.
//

#import "HUPlaylistTableViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HUPlayerTableViewController.h"

@interface HUPlaylistTableViewController ()

    @property (nonatomic, strong) NSArray *playlists;

@end

@implementation HUPlaylistTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Power Hourish"];
    
    MPMediaQuery *myPlaylistsQuery = [MPMediaQuery playlistsQuery];
    self.playlists = [myPlaylistsQuery collections];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.playlists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlaylistCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UILabel *nameLabel = (UILabel*)[cell viewWithTag:21];
    UILabel *songCountLabel = (UILabel*)[cell viewWithTag:22];
    
    MPMediaPlaylist *playlist = self.playlists[indexPath.row];
    
    nameLabel.text = [playlist valueForProperty:MPMediaPlaylistPropertyName];
    
    NSInteger songCount = [playlist.items count];
    songCountLabel.text = [NSString stringWithFormat:@"%ld Songs", songCount];

    return cell;
}

- (MPMediaPlaylist*)currentlySelectedPlaylist {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    if (path) {
        return self.playlists[path.row];
    } else {
        return nil;
    }
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    MPMediaPlaylist* playlist = [self currentlySelectedPlaylist];
    NSLog(@"playlist items = %@", [playlist items]);
    
    if (playlist.items.count > 0) {
        return YES;
    } else {
        [[[UIAlertView alloc] initWithTitle:@"No Songs In Playlist" message:@"Please select a list with something in it." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
        return NO;
    }
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MPMediaPlaylist *playlist = [self currentlySelectedPlaylist];
    HUPlayerTableViewController *player = (HUPlayerTableViewController*)[segue destinationViewController];
    player.playlist = playlist;
}

@end
