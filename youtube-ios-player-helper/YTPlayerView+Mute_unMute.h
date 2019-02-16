//
//  YTPlayerView+Mute_unMute.h
//  YouTubeiOSPlayerHelper
//
//  Created by Abhay Singh Naurang on 16/02/19.
//  Copyright © 2019 YouTube Developer Relations. All rights reserved.
//

#import <YouTubeiOSPlayerHelper/YouTubeiOSPlayerHelper.h>

NS_ASSUME_NONNULL_BEGIN
/** These enums represent the state of the current video in the player. */
typedef NS_ENUM(NSInteger, YTPlayerMuteState) {
    kYTPlayerMuteStateUnMuted = 0,
    kYTPlayerMuteStateMuted = 1,
};

@interface YTPlayerView (Mute_unMute)
/**
 * mute or resumes playback on the loaded video. Corresponds to this method from
 * the JavaScript API:
 *   https://developers.google.com/youtube/iframe_api_reference#mute
 */
- (void)muteVideo;

/**
 * unMute playback on a playing video. Corresponds to this method from
 * the JavaScript API:
 *   https://developers.google.com/youtube/iframe_api_reference#mute
 */
- (void)unMuteVideo;
/**
 * muteState playback on a playing video. Corresponds to this method from
 * the JavaScript API:
 *   https://developers.google.com/youtube/iframe_api_reference#mute
 */
- (BOOL)isMuted;
@end

NS_ASSUME_NONNULL_END
