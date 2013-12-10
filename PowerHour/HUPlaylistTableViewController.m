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

@interface HUPlaylistTableViewController () {
    NSArray *playlists;
}

@end

@implementation HUPlaylistTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Power Hourish"];
    
    MPMediaQuery *myPlaylistsQuery = [MPMediaQuery playlistsQuery];
    playlists = [myPlaylistsQuery collections];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [playlists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlaylistCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UILabel *nameLabel = (UILabel*)[cell viewWithTag:21];
    UILabel *songCountLabel = (UILabel*)[cell viewWithTag:22];
    
    MPMediaPlaylist *playlist = playlists[indexPath.row];
    
    nameLabel.text = [playlist valueForProperty:MPMediaPlaylistPropertyName];
    
    NSInteger songCount = [playlist.items count];
    songCountLabel.text = [NSString stringWithFormat:@"%d Songs", songCount];
    

    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    MPMediaPlaylist *playlist = playlists[path.row];
    HUPlayerTableViewController *player = (HUPlayerTableViewController*)[segue destinationViewController];
    player.playlist = playlist;
    
}


@end
