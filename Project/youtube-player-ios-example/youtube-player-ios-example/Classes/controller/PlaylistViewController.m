// Copyright 2014 Google Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "PlaylistViewController.h"

@implementation PlaylistViewController

@synthesize lbl_time_now;
@synthesize lbl_time_total;
@synthesize slider_time;
@synthesize isTrackLogged;
@synthesize lyric;
@synthesize lang_selected;
@synthesize lyric_type_selected;

- (void)viewDidLoad {
  [super viewDidLoad];
    
    NSString* playlistId = URL_YOUTUBE_PLAYLIST;//@"PLhBgTdAWkxeCMHYCQ0uuLyhydRJGDRNo5";

    // For a full list of player parameters, see the documentation for the HTML5 player
    // at: https://developers.google.com/youtube/player_parameters?playerVersion=HTML5
    NSDictionary *playerVars = @{
                                 @"controls" : @0,
                                 @"playsinline" : @1,
                                 @"autohide" : @1,
                                 @"showinfo" : @0,
                                 @"modestbranding" : @1
                                };
    self.playerView.delegate = self;

    [self.playerView loadWithPlaylistId:playlistId playerVars:playerVars];
    
    // initial lyric parameters
    lyric = [[Lyric alloc] init];
    lang_selected = @"en";
    lyric_type_selected = LyricOriginal;
    list_langs = [self loadAvailableLanguages];
    
    isKaraokeEnabled = TRUE;
    isTranslationEnabled =  TRUE;
    isSecretEnabled = TRUE;
    
    [self.btn_type_original setSelected:TRUE];
    [self.btn_type_translation setSelected:TRUE];
    [self.btn_type_karaoke setSelected:TRUE];
    [self.btn_type_secret setSelected:TRUE];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedPlaybackStartedNotification:)
                                               name:@"Playback started"
                                             object:nil];
}

- (IBAction)buttonPressed:(id)sender {
    if (sender == self.playButton) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Playback started"
                                                          object:self];
        [self.playerView playVideo];
//        [self loadingVideoLyric];
        [self startUpdateTimer];
        [self clearAllData];
        
      
    } else if (sender == self.pauseButton) {
        [self.playerView pauseVideo];
        [self pauseTimer];
        [self refreshData];
      
    } else if (sender == self.stopButton) {
      [self.playerView stopVideo];
      [self stopUpdateTimer];
        [self clearAllData];
      
    } else if (sender == self.nextVideoButton) {
        [self resetTimer];
        [self startUpdateTimer];
        [self appendStatusText:@"Loading next video in playlist\n"];
        [self.playerView nextVideo];
//        [self loadingVideoLyric];
        [self clearAllData];
        
        
      
    } else if (sender == self.previousVideoButton) {
        [self resetTimer];
        [self startUpdateTimer];
        [self appendStatusText:@"Loading previous video in playlist\n"];
        [self.playerView previousVideo];
//        [self loadingVideoLyric];
        [self clearAllData];
        
        
    } else if (sender == self.btn_type_karaoke) {
        [self.btn_type_karaoke setSelected: !self.btn_type_karaoke.isSelected];
        self.lyric_type_selected = LyricKarakoke;
        if(self.btn_type_karaoke.isSelected){
            [self __showOptionViewFromBtn:self.btn_type_karaoke];
            isKaraokeEnabled = TRUE;
        }else{
            [self __hideOptionViewFromBtn:self.btn_type_karaoke];
        }
        [self refreshData];
        
    } else if (sender == self.btn_type_translation) {
        [self.btn_type_translation setSelected: !self.btn_type_translation.isSelected];
        self.lyric_type_selected = LyricTranslation;
        if(self.btn_type_translation.isSelected){
            [self __showOptionViewFromBtn:self.btn_type_translation];
            isTranslationEnabled = TRUE;
        }else{
            [self __hideOptionViewFromBtn:self.btn_type_translation];
        }
        
        
    } else if (sender == self.btn_type_original) {
        [self.btn_type_original setSelected: !self.btn_type_original.isSelected];
        self.lyric_type_selected = LyricOriginal;
        if(self.btn_type_original.isSelected){
            [self __showOptionViewFromBtn:self.btn_type_original];
          
        }else{
            [self __hideOptionViewFromBtn:self.btn_type_original];
        }
        [self refreshData];
   
    }else if (sender == self.btn_type_secret) {
        [self.btn_type_secret setSelected: !self.btn_type_secret.isSelected];
        self.lyric_type_selected = LyricSecret;
        if(self.btn_type_secret.isSelected){
            [self __showOptionViewFromBtn:self.btn_type_secret];
            isSecretEnabled = TRUE;
        }else{
            [self __hideOptionViewFromBtn:self.btn_type_secret];
        }
        [self refreshData];
        
    }
    
    
}

#pragma mark - PlayerView Delegate
- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView
{
    NSLog(@"Video come ready--");
    [self clearAllData];
    [self loadingVideoLyric];
}

-(void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state
{
    if(state == kYTPlayerStateEnded)
    {
        NSLog(@"Play at : %d", [self.playerView playlistIndex] );
        [self clearAllData];
        
    }
    
    else if(state == kYTPlayerStateBuffering)
    {
        NSLog(@"Play at : %d", [self.playerView playlistIndex] );
        [self clearAllData];
        [self loadingVideoLyric];
        [self startUpdateTimer];
    }
    
    else if(state == kYTPlayerStatePaused)
    {
        [self pauseTimer];
    }
    
    else if(state == kYTPlayerStateEnded)
    {
        [self stopUpdateTimer];
    }

}

#pragma mark - SearchBar Delegate
- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // TODO: search for text after some text has been changed
}

- (void) searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    // TODO: search result after select from the list
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // TODO: search result after button click
    NSLog(@"-- bar button click --");
}

- (void)receivedPlaybackStartedNotification:(NSNotification *) notification {
    if([notification.name isEqual:@"Playback started"] && notification.object != self) {
        [self.playerView pauseVideo];
    }
}

/**
 * Private helper method to add player status in statusTextView and scroll view automatically.
 *
 * @param status a string describing current player state
 */
- (void)appendStatusText:(NSString*)status {
  [self.statusTextView setText:[self.statusTextView.text stringByAppendingString:status]];
  NSRange range = NSMakeRange(self.statusTextView.text.length - 1, 1);

  // To avoid dizzying scrolling on appending latest status.
  self.statusTextView.scrollEnabled = NO;
  [self.statusTextView scrollRangeToVisible:range];
  self.statusTextView.scrollEnabled = YES;
}

#pragma mark - Picker Method
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    LyricLang *lyricLang = [list_langs objectAtIndex:row];
    return lyricLang.name_long;
    //return @"";
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    LyricLang *lyricLang = [list_langs objectAtIndex:row];
    lang_selected = lyricLang.name_short;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    if(component == 0){
        
        if([list_langs count] <= 0){
            return 0;
        }
        return 1;
        //return [list_langs count];
    }
    
    return 0;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 20;
}

#pragma mark - Timer Method

- (void)startUpdateTimer
{
    [self stopUpdateTimer];
    
    timer_video = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                   target:self
                                                 selector:@selector(onTimerUpdate)
                                                 userInfo:nil
                                                  repeats:YES];
    
}

- (void)pauseTimer
{
    [self stopUpdateTimer];
}

- (void)stopUpdateTimer
{
    if (timer_video) {
        [timer_video invalidate];
        timer_video = nil;
    }
    
    [self.slider_time setValue:0.0 animated:YES];
}

- (void)resetTimer
{
    [self stopUpdateTimer];
}

- (void)onTimerUpdate
{
    double length = [self getVideoTotalTime];
    double position = [self getVideoCurrentTime];
    
    
    if (length >= 0 && position >= 0) {
        int timeM = (int)position / 60;
        int timeS = (int)position % 60;
        
        int totalM = (int)length / 60;
        int totalS = (int)length % 60;
        
        self.slider_time.value = position / length;
        
        NSString *timePlayString = [NSString stringWithFormat:@"%d:%02d", timeM, timeS];
        NSString *timeTotalString = [NSString stringWithFormat:@"%d:%02d", totalM, totalS];
        
        NSLog(@"TimePlay(%@/%@)", timePlayString, timeTotalString);
        [self loadDataAtTime:timePlayString];
        
        self.lbl_time_now.text = timePlayString;
        self.lbl_time_total.text = timeTotalString;
    } else {
        self.slider_time.value = 0;
        
        self.lbl_time_now.text = @"00:00";
        self.lbl_time_total.text = @"00:00";
    }
    
    // Insert to log about current track at 30 seconds after played
    if(((int)position % 60) == 30  && !self.isTrackLogged){
        self.isTrackLogged = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            NSLog(@"Time reach to 30 seconds...");
//            NSMutableDictionary *mediaInfo = [[BBMusicPlayer sharedInstance] currentMediaInfo];
//            NSString *title = [mediaInfo objectForKey:@"title"];
//            NSString *album = [mediaInfo objectForKey:@"album"];
//            NSString *artist = [mediaInfo objectForKey:@"artist"];
//            [[Util sharedUtil] insertCurrentTrackwithTitle:title album:album artist:artist];
            
        });
    }
}

#pragma mark - Private method

- (double)getVideoTotalTime
{
    return [self.playerView duration];
}

- (double)getVideoCurrentTime
{
    return [self.playerView currentTime];
}

- (void) loadingVideoLyric
{
    NSLog(@"Current playlist index: %d", [self.playerView playlistIndex] );
    NSString *videoURL = [[self.playerView videoUrl] absoluteString];
    NSLog(@"Video URL: %@", videoURL);
    NSLog(@"%@", [self.playerView videoUrl]);
    NSLog(@"%@", [self.playerView videoEmbedCode]);
    
    NSError* error = nil;
    //v=[^&]*
    //v=([^&]+)
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"v=([^&]+)" options:0 error:&error];
    NSArray* matches = [regex matchesInString:videoURL options:0 range:NSMakeRange(0, [videoURL length])];
    if(matches!=nil){
        
        NSTextCheckingResult *match = [matches objectAtIndex:0];
        NSString* matchText = [videoURL substringWithRange:[match range]];
        NSString* videoID = [matchText substringWithRange:NSMakeRange(2, [matchText length]-2)];
        NSLog(@"match: %@", matchText);
        NSLog(@"videoID: %@", videoID);
        [lyric searchDataWithTitle:videoID
                         andArtist:@"-"
                    andDescription:@""
                           andType:LyricTranslation
                           andLang:@"en"];
    
//    if( [self.playerView playlistIndex] == 0 ){
//        [lyric searchDataWithTitle:@"ในหลวงของแผ่นดิน"
//                         andArtist:@"-"
//                    andDescription:@""
//                           andType:LyricTranslation
//                           andLang:@"en"];
//    }else if( [self.playerView playlistIndex] == 1 ){
//        [lyric searchDataWithTitle:@"Serendipity"
//                               andArtist:@"-"
//                          andDescription:@""
//                                 andType:LyricTranslation
//                                 andLang:@"en"];
//    }else if( [self.playerView playlistIndex] == 2 ){
//        [lyric searchDataWithTitle:@"ไกลแค่ไหนคือใกล้"
//                         andArtist:@"-"
//                    andDescription:@""
//                           andType:LyricTranslation
//                           andLang:@"en"];
//    }
        
    }

}

- (void) loadDataAtTime:(NSString*) atTime
{
    NSLog(@"Search Time:%@", atTime);
    //self.lyricView.text = [lyric retrieveLyricInfoAtTime:atTime];
    NSString *search = [NSString stringWithFormat:@"%@", atTime];
    
    self.textview_lyric.text = [lyric retrieveLyricInfoAtTime:search];
    
    if(isKaraokeEnabled){
        self.textview_karaoke.text = [lyric retrieveKaraokeInfoAtTime:search];
    }
    
    if(isTranslationEnabled){
        self.textview_translation.text = [lyric retrieveTranslationInfoAtTime:search];
    }
    
    if(isSecretEnabled){
        self.textview_secret.text = [lyric retrieveSecretInfoAtTime:search];
    }
}


- (void) refreshData
{
    self.textview_lyric.text = [lyric current_lyric_line];
    self.textview_karaoke.text = [lyric current_karaoke_line];
    self.textview_translation.text = [lyric current_translation_line];
    self.textview_secret.text = [lyric current_secret_line];
    
}

- (void) clearAllData
{
    [lyric clearCurrentLyric];
    
    self.textview_lyric.text = @"...Lyrics...";
    self.textview_karaoke.text = @"...Karaoke...";
    self.textview_translation.text = @"...Translation...";
    self.textview_secret.text = @"...Secret Lyrics...";

}

- (NSMutableArray*) loadAvailableLanguages
{
    // TODO service to provide language list
    NSMutableArray *langs = [[NSMutableArray alloc] init];
    LyricLang *lang_en = [[LyricLang alloc] initWithName:@"en"
                                             andLongName:@"English"
                                          andDescription:@""];
    LyricLang *lang_th = [[LyricLang alloc] initWithName:@"th"
                                             andLongName:@"Thai"
                                          andDescription:@""];
    LyricLang *lang_kr = [[LyricLang alloc] initWithName:@"kr"
                                             andLongName:@"Korean"
                                          andDescription:@""];
    LyricLang *lang_jp = [[LyricLang alloc] initWithName:@"jp"
                                             andLongName:@"Japanese"
                                          andDescription:@""];
    LyricLang *lang_ch = [[LyricLang alloc] initWithName:@"ch"
                                             andLongName:@"Chinese"
                                          andDescription:@""];
    LyricLang *lang_vi = [[LyricLang alloc] initWithName:@"vi"
                                             andLongName:@"Vietnamese"
                                          andDescription:@""];
    LyricLang *lang_ar = [[LyricLang alloc] initWithName:@"ar"
                                             andLongName:@"Arabic"
                                          andDescription:@""];
 
    [langs addObject:lang_en];
    [langs addObject:lang_th];
    [langs addObject:lang_kr];
    [langs addObject:lang_jp];
    [langs addObject:lang_ch];
    [langs addObject:lang_vi];
    [langs addObject:lang_ar];
    
    return langs;
}

- (void)__showOptionViewFromBtn:(UIButton*) btn
{
    self.textview_karaoke.hidden = NO;
    if(btn == self.btn_type_karaoke){
        self.constraint_textview_karaoke_height.constant = 29;
        [self.textview_karaoke setNeedsUpdateConstraints];
    }else if(btn == self.btn_type_translation){
        self.constraint_textview_translation_height.constant = 29;
        [self.textview_translation setNeedsUpdateConstraints];
    }else if(btn == self.btn_type_original){
        self.constraint_textview_original_height.constant = 29;
        [self.textview_lyric setNeedsUpdateConstraints];
    }else if(btn == self.btn_type_secret){
        self.constraint_textview_secret_height.constant = 29;
        [self.textview_secret setNeedsUpdateConstraints];
    }
    
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.textview_karaoke layoutIfNeeded];
                         [self.textview_secret layoutIfNeeded];
                         [self.textview_translation layoutIfNeeded];
                         [self.textview_lyric layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)__hideOptionViewFromBtn:(UIButton*) btn
{
//    self.btn_option.selected = NO;
    
    
    if(btn == self.btn_type_karaoke){
        self.constraint_textview_karaoke_height.constant = 0;
        [self.textview_karaoke setNeedsUpdateConstraints];
    }else if(btn == self.btn_type_translation){
        self.constraint_textview_translation_height.constant = 0;
        [self.textview_translation setNeedsUpdateConstraints];
    }else if(btn == self.btn_type_original){
        self.constraint_textview_original_height.constant = 0;
        [self.textview_lyric setNeedsUpdateConstraints];
    }else if(btn == self.btn_type_secret){
        self.constraint_textview_secret_height.constant = 0;
        [self.textview_secret setNeedsUpdateConstraints];
    }
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         
                         if(btn == self.btn_type_karaoke){
                             [self.textview_karaoke layoutIfNeeded];
                         }else if(btn == self.btn_type_translation){
                             [self.textview_translation layoutIfNeeded];
                         }else if(btn == self.btn_type_original){
                             [self.textview_lyric layoutIfNeeded];
                         }else if(btn == self.btn_type_secret){
                             [self.textview_secret layoutIfNeeded];
                         }
 
                         
                     }
                     completion:^(BOOL finished) {
//                         self.btn_option.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
                         //self.textview_karaoke.hidden = YES;
                     }];
}

//- (void)pushViewController:(UIViewController *)vc
//                  animated:(BOOL)animated
//{
////    if (self.isTransitioningScreen) {
////        return;
////    }
//    @synchronized(self) {
////        self.isTransitioningScreen = YES;
//        [self.vcList addObject:vc];
//        [self addChildViewController:vc];
//        [self.view_subview addSubview:vc.view];
//        [vc didMoveToParentViewController:self];
//        
//        if (animated) {
//            vc.view.frame = CGRectMake(self.view_subview.frame.size.width, 0, self.view_subview.bounds.size.width, self.view_subview.bounds.size.height);
//            
//            [UIView animateWithDuration:0.5
//                             animations:^{
//                                 vc.view.frame = self.view_subview.bounds;
//                                 
//                                 if (self.activeVC) {
//                                     CGRect frame = self.activeVC.view.frame;
//                                     frame.origin.x = -frame.size.width;
//                                     self.activeVC.view.frame = frame;
//                                 }
//                             }
//                             completion:^(BOOL finished) {
//                                 if (self.activeVC) {
//                                     [self.activeVC.view removeFromSuperview];
//                                     [self.activeVC removeFromParentViewController];
//                                 }
//                                 
//                                 self.activeVC = vc;
//                                 
//                                 self.isTransitioningScreen = NO;
//                             }];
//        } else {
//            vc.view.frame = self.view_subview.bounds;
//            
//            if (self.activeVC) {
//                [self.activeVC.view removeFromSuperview];
//                [self.activeVC removeFromParentViewController];
//            }
//            
//            self.activeVC = vc;
//            
//            self.isTransitioningScreen = NO;
//        }
//    }
//}

@end