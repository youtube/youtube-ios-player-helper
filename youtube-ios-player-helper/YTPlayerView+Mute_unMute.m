//
//  YTPlayerView+Mute_unMute.m
//  YouTubeiOSPlayerHelper
//
//  Created by Abhay Singh Naurang on 16/02/19.
//  Copyright © 2019 YouTube Developer Relations. All rights reserved.
//

#import "YTPlayerView+Mute_unMute.h"

NSString static *const kYTPlayerMuteStateUnMutedCode = @"false";
NSString static *const kYTPlayerMuteStateMutedCode = @"true";

@implementation YTPlayerView (Mute_unMute)


#pragma mark - Player methods

-(void)muteVideo{
    [self.webView stringByEvaluatingJavaScriptFromString:@"player.mute();"];
}

-(void)unMuteVideo{
    [self.webView stringByEvaluatingJavaScriptFromString:@"player.unMute();"];
}

- (BOOL)isMuted {
    NSString *returnValue = [self.webView stringByEvaluatingJavaScriptFromString:@"player.isMuted()"];
    return [YTPlayerView playerPlayerMuteStateForString:returnValue];
}

/**
 * Convert a state value from NSString to the typed enum value.
 *
 * @param stateString A string representing player mute state. Ex: "false", "true".
 * @return An enum value representing the player mute state.
 */
+ (YTPlayerMuteState)playerPlayerMuteStateForString:(NSString *)stateString {
    YTPlayerMuteState state = kYTPlayerMuteStateUnMuted;
    if ([stateString isEqualToString:kYTPlayerMuteStateUnMutedCode]) {
        state = kYTPlayerMuteStateUnMuted;
    } else if ([stateString isEqualToString:kYTPlayerMuteStateMutedCode]) {
        state = kYTPlayerMuteStateMuted;
    }
    return state;
}
@end
