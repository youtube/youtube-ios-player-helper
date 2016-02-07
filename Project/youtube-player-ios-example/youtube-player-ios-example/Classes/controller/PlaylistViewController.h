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

#import "YTPlayerView.h"
#import "Lyric.h"
#import "LyricLang.h"

@interface PlaylistViewController : UIViewController<YTPlayerViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UISearchBarDelegate>
{
    int time_video_pos;
    int time_video_total;
    BOOL isTrackLogged;
    BOOL isTranslationEnabled;
    BOOL isKaraokeEnabled;
    BOOL isSecretEnabled;
    NSString *lang_selected;
    
    NSTimer *timer_video;
    Lyric *lyric;
    LyricType lyric_type_selected;
    NSMutableArray *list_langs;
}

@property(nonatomic, readwrite) BOOL isTrackLogged;
@property(nonatomic, readwrite) NSString* lang_selected;
@property(nonatomic, strong) Lyric *lyric;
@property(nonatomic, readwrite) LyricType lyric_type_selected;

@property(nonatomic, strong) IBOutlet YTPlayerView *playerView;
@property(nonatomic, strong) IBOutlet UILabel *lbl_time_now;
@property(nonatomic, strong) IBOutlet UILabel *lbl_time_total;
@property(nonatomic, strong) IBOutlet UISlider *slider_time;

@property(nonatomic, weak) IBOutlet UIButton *playButton;
@property(nonatomic, weak) IBOutlet UIButton *pauseButton;
@property(nonatomic, weak) IBOutlet UIButton *stopButton;
@property(nonatomic, weak) IBOutlet UIButton *nextVideoButton;
@property(nonatomic, weak) IBOutlet UIButton *previousVideoButton;
@property(nonatomic, weak) IBOutlet UITextView *statusTextView;
@property(nonatomic, weak) IBOutlet UITextView *textview_lyric;
@property(nonatomic, weak) IBOutlet UITextView *textview_translation;
@property(nonatomic, weak) IBOutlet UITextView *textview_karaoke;
@property(nonatomic, weak) IBOutlet UITextView *textview_secret;

//@property(nonatomic, strong) IBOutlet UIView *view_lyric_view;
@property(nonatomic, strong) IBOutlet UIButton *btn_type_original;
@property(nonatomic, strong) IBOutlet UIButton *btn_type_translation;
@property(nonatomic, strong) IBOutlet UIButton *btn_type_karaoke;
@property(nonatomic, strong) IBOutlet UIButton *btn_type_secret;
@property(nonatomic, strong) IBOutlet UIPickerView *picker_lang;
@property(nonatomic, strong) IBOutlet UISearchBar *search_lang;

@property(nonatomic, strong) IBOutlet NSLayoutConstraint *constraint_textview_translation_height;
@property(nonatomic, strong) IBOutlet NSLayoutConstraint *constraint_textview_original_height;
@property(nonatomic, strong) IBOutlet NSLayoutConstraint *constraint_textview_secret_height;
@property(nonatomic, strong) IBOutlet NSLayoutConstraint *constraint_textview_karaoke_height;

- (IBAction)buttonPressed:(id)sender;

@end