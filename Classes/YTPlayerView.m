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

// These are instances of NSString because we get them from parsing a URL. It would be silly to
// convert these into an integer just to have to convert the URL query string value into an integer
// as well for the sake of doing a value comparison. A full list of response error codes can be
// found here:
//      https://developers.google.com/youtube/iframe_api_reference
NSString static *const kYTPlayerStateUnstartedCode = @"-1";
NSString static *const kYTPlayerStateEndedCode = @"0";
NSString static *const kYTPlayerStatePlayingCode = @"1";
NSString static *const kYTPlayerStatePausedCode = @"2";
NSString static *const kYTPlayerStateBufferingCode = @"3";
NSString static *const kYTPlayerStateCuedCode = @"5";
NSString static *const kYTPlayerStateUnknownCode = @"unknown";

// Constants representing playback quality.
NSString static *const kYTPlaybackQualitySmallQuality = @"small";
NSString static *const kYTPlaybackQualityMediumQuality = @"medium";
NSString static *const kYTPlaybackQualityLargeQuality = @"large";
NSString static *const kYTPlaybackQualityHD720Quality = @"hd720";
NSString static *const kYTPlaybackQualityHD1080Quality = @"hd1080";
NSString static *const kYTPlaybackQualityHighResQuality = @"highres";
NSString static *const kYTPlaybackQualityAutoQuality = @"auto";
NSString static *const kYTPlaybackQualityDefaultQuality = @"default";
NSString static *const kYTPlaybackQualityUnknownQuality = @"unknown";

// Constants representing YouTube player errors.
NSString static *const kYTPlayerErrorInvalidParamErrorCode = @"2";
NSString static *const kYTPlayerErrorHTML5ErrorCode = @"5";
NSString static *const kYTPlayerErrorVideoNotFoundErrorCode = @"100";
NSString static *const kYTPlayerErrorNotEmbeddableErrorCode = @"101";
NSString static *const kYTPlayerErrorCannotFindVideoErrorCode = @"105";
NSString static *const kYTPlayerErrorSameAsNotEmbeddableErrorCode = @"150";

// Constants representing player callbacks.
NSString static *const kYTPlayerCallbackOnReady = @"onReady";
NSString static *const kYTPlayerCallbackOnStateChange = @"onStateChange";
NSString static *const kYTPlayerCallbackOnPlaybackQualityChange = @"onPlaybackQualityChange";
NSString static *const kYTPlayerCallbackOnError = @"onError";
NSString static *const kYTPlayerCallbackOnPlayTime = @"onPlayTime";

NSString static *const kYTPlayerCallbackOnYouTubeIframeAPIReady = @"onYouTubeIframeAPIReady";
NSString static *const kYTPlayerCallbackOnYouTubeIframeAPIFailedToLoad = @"onYouTubeIframeAPIFailedToLoad";

NSString static *const kYTPlayerEmbedUrlRegexPattern = @"^http(s)://(www.)youtube.com/embed/(.*)$";
NSString static *const kYTPlayerAdUrlRegexPattern = @"^http(s)://pubads.g.doubleclick.net/pagead/conversion/";
NSString static *const kYTPlayerOAuthRegexPattern = @"^http(s)://accounts.google.com/o/oauth2/(.*)$";
NSString static *const kYTPlayerStaticProxyRegexPattern = @"^https://content.googleapis.com/static/proxy.html(.*)$";
NSString static *const kYTPlayerSyndicationRegexPattern = @"^https://tpc.googlesyndication.com/sodar/(.*).html$";

@interface YTPlayerView() <WKNavigationDelegate>

@property (nonatomic) NSURL *originURL;
@property (nonatomic, weak) UIView *initialLoadingView;

@end

@implementation YTPlayerView

- (BOOL)loadWithVideoId:(NSString *)videoId {
  return [self loadWithVideoId:videoId playerVars:nil];
}

- (BOOL)loadWithPlaylistId:(NSString *)playlistId {
  return [self loadWithPlaylistId:playlistId playerVars:nil];
}

- (BOOL)loadWithVideoId:(NSString *)videoId playerVars:(NSDictionary *)playerVars {
  if (!playerVars) {
    playerVars = @{};
  }
  NSDictionary *playerParams = @{ @"videoId" : videoId, @"playerVars" : playerVars };
  return [self loadWithPlayerParams:playerParams];
}

- (BOOL)loadWithPlaylistId:(NSString *)playlistId playerVars:(NSDictionary *)playerVars {

  // Mutable copy because we may have been passed an immutable config dictionary.
  NSMutableDictionary *tempPlayerVars = [[NSMutableDictionary alloc] init];
  [tempPlayerVars setValue:@"playlist" forKey:@"listType"];
  [tempPlayerVars setValue:playlistId forKey:@"list"];
  if (playerVars) {
    [tempPlayerVars addEntriesFromDictionary:playerVars];
  }

  NSDictionary *playerParams = @{ @"playerVars" : tempPlayerVars };
  return [self loadWithPlayerParams:playerParams];
}

#pragma mark - Player methods

- (void)playVideo {
  [self evaluateJavaScript:@"player.playVideo();"];
}

- (void)pauseVideo {
  [self notifyDelegateOfYouTubeCallbackUrl:[NSURL URLWithString:[NSString stringWithFormat:@"ytplayer://onStateChange?data=%@", kYTPlayerStatePausedCode]]];
  [self evaluateJavaScript:@"player.pauseVideo();"];
}

- (void)stopVideo {
  [self evaluateJavaScript:@"player.stopVideo();"];
}

- (void)seekToSeconds:(float)seekToSeconds allowSeekAhead:(BOOL)allowSeekAhead {
  NSNumber *secondsValue = [NSNumber numberWithFloat:seekToSeconds];
  NSString *allowSeekAheadValue = [self stringForJSBoolean:allowSeekAhead];
  NSString *command = [NSString stringWithFormat:@"player.seekTo(%@, %@);", secondsValue, allowSeekAheadValue];
  [self evaluateJavaScript:command];
}

#pragma mark - Cueing methods

- (void)cueVideoById:(NSString *)videoId
        startSeconds:(float)startSeconds {
  NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
  NSString *command = [NSString stringWithFormat:@"player.cueVideoById('%@', %@);",
      videoId, startSecondsValue];
  [self evaluateJavaScript:command];
}

- (void)cueVideoById:(NSString *)videoId
        startSeconds:(float)startSeconds
          endSeconds:(float)endSeconds {
  NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
  NSNumber *endSecondsValue = [NSNumber numberWithFloat:endSeconds];
  NSString *command = [NSString stringWithFormat:@"player.cueVideoById({'videoId': '%@',"
                       "'startSeconds': %@, 'endSeconds': %@});",
                       videoId, startSecondsValue, endSecondsValue];
  [self evaluateJavaScript:command];
}

- (void)loadVideoById:(NSString *)videoId
         startSeconds:(float)startSeconds {
  NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
  NSString *command = [NSString stringWithFormat:@"player.loadVideoById('%@', %@);",
      videoId, startSecondsValue];
  [self evaluateJavaScript:command];
}

- (void)loadVideoById:(NSString *)videoId
         startSeconds:(float)startSeconds
           endSeconds:(float)endSeconds {
  NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
  NSNumber *endSecondsValue = [NSNumber numberWithFloat:endSeconds];
  NSString *command = [NSString stringWithFormat:@"player.loadVideoById({'videoId': '%@',"
                       "'startSeconds': %@, 'endSeconds': %@});",
                       videoId, startSecondsValue, endSecondsValue];
  [self evaluateJavaScript:command];
}

- (void)cueVideoByURL:(NSString *)videoURL
         startSeconds:(float)startSeconds {
  NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
  NSString *command = [NSString stringWithFormat:@"player.cueVideoByUrl('%@', %@);",
      videoURL, startSecondsValue];
  [self evaluateJavaScript:command];
}

- (void)cueVideoByURL:(NSString *)videoURL
         startSeconds:(float)startSeconds
           endSeconds:(float)endSeconds {
  NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
  NSNumber *endSecondsValue = [NSNumber numberWithFloat:endSeconds];
  NSString *command = [NSString stringWithFormat:@"player.cueVideoByUrl('%@', %@, %@);",
      videoURL, startSecondsValue, endSecondsValue];
  [self evaluateJavaScript:command];
}

- (void)loadVideoByURL:(NSString *)videoURL
          startSeconds:(float)startSeconds {
  NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
  NSString *command = [NSString stringWithFormat:@"player.loadVideoByUrl('%@', %@);",
      videoURL, startSecondsValue];
  [self evaluateJavaScript:command];
}

- (void)loadVideoByURL:(NSString *)videoURL
          startSeconds:(float)startSeconds
            endSeconds:(float)endSeconds {
  NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
  NSNumber *endSecondsValue = [NSNumber numberWithFloat:endSeconds];
  NSString *command = [NSString stringWithFormat:@"player.loadVideoByUrl('%@', %@, %@);",
      videoURL, startSecondsValue, endSecondsValue];
  [self evaluateJavaScript:command];
}

#pragma mark - Cueing methods for lists

- (void)cuePlaylistByPlaylistId:(NSString *)playlistId
                          index:(int)index
                   startSeconds:(float)startSeconds {
  NSString *playlistIdString = [NSString stringWithFormat:@"'%@'", playlistId];
  [self cuePlaylist:playlistIdString
                 index:index
          startSeconds:startSeconds];
}

- (void)cuePlaylistByVideos:(NSArray *)videoIds
                      index:(int)index
               startSeconds:(float)startSeconds {
  [self cuePlaylist:[self stringFromVideoIdArray:videoIds]
                 index:index
          startSeconds:startSeconds];
}

- (void)loadPlaylistByPlaylistId:(NSString *)playlistId
                           index:(int)index
                    startSeconds:(float)startSeconds {
  NSString *playlistIdString = [NSString stringWithFormat:@"'%@'", playlistId];
  [self loadPlaylist:playlistIdString
                 index:index
          startSeconds:startSeconds];
}

- (void)loadPlaylistByVideos:(NSArray *)videoIds
                       index:(int)index
                startSeconds:(float)startSeconds {
  [self loadPlaylist:[self stringFromVideoIdArray:videoIds]
                 index:index
          startSeconds:startSeconds];
}

#pragma mark - Setting the playback rate

- (void)playbackRate:(_Nullable YTFloatCompletionHandler)completionHandler {
  [self evaluateJavaScript:@"player.getPlaybackRate();"
         completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
    if (!completionHandler) {
      return;
    }
    if (error) {
      completionHandler(-1, error);
      return;
    }
    if (!result || ![result isKindOfClass:[NSNumber class]]) {
      completionHandler(0, nil);
      return;
    }
    completionHandler([result floatValue], nil);
  }];
}

- (void)setPlaybackRate:(float)suggestedRate {
  NSString *command = [NSString stringWithFormat:@"player.setPlaybackRate(%f);", suggestedRate];
  [self evaluateJavaScript:command];
}

- (void)availablePlaybackRates:(_Nullable YTArrayCompletionHandler)completionHandler {
  [self evaluateJavaScript:@"player.getAvailablePlaybackRates();"
         completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
    if (!completionHandler) {
      return;
    }
    if (error) {
      completionHandler(nil, error);
      return;
    }
    if (!result || ![result isKindOfClass:[NSArray class]]) {
      completionHandler(nil, nil);
      return;
    }
    completionHandler(result, nil);
  }];
}

#pragma mark - Setting playback behavior for playlists

- (void)setLoop:(BOOL)loop {
  NSString *loopPlayListValue = [self stringForJSBoolean:loop];
  NSString *command = [NSString stringWithFormat:@"player.setLoop(%@);", loopPlayListValue];
  [self evaluateJavaScript:command];
}

- (void)setShuffle:(BOOL)shuffle {
  NSString *shufflePlayListValue = [self stringForJSBoolean:shuffle];
  NSString *command = [NSString stringWithFormat:@"player.setShuffle(%@);", shufflePlayListValue];
  [self evaluateJavaScript:command];
}

#pragma mark - Playback status

- (void)videoLoadedFraction:(_Nullable YTFloatCompletionHandler)completionHandler {
  [self evaluateJavaScript:@"player.getVideoLoadedFraction();"
         completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
    if (!completionHandler) {
      return;
    }
    if (error) {
      completionHandler(-1, error);
      return;
    }
    if (!result || ![result isKindOfClass:[NSNumber class]]) {
      completionHandler(0, nil);
      return;
    }
    completionHandler([result floatValue], nil);
  }];
}

- (void)playerState:(_Nullable YTPlayerStateCompletionHandler)completionHandler {
  [self evaluateJavaScript:@"player.getPlayerState();"
         completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
    if (!completionHandler) {
      return;
    }
    if (error) {
      completionHandler(kYTPlayerStateUnknown, error);
      return;
    }
    if (!result || ![result isKindOfClass:[NSNumber class]]) {
      completionHandler(kYTPlayerStateUnknown, error);
      return;
    }
    YTPlayerState state = [YTPlayerView playerStateForString:[result stringValue]];
    completionHandler(state, nil);
  }];
}

- (void)currentTime:(_Nullable YTFloatCompletionHandler)completionHandler {
  [self evaluateJavaScript:@"player.getCurrentTime();"
         completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
    if (!completionHandler) {
      return;
    }
    if (error) {
      completionHandler(-1, error);
      return;
    }
    if (!result || ![result isKindOfClass:[NSNumber class]]) {
      completionHandler(0, nil);
      return;
    }
    completionHandler([result floatValue], nil);
  }];
}

#pragma mark - Video information methods

- (void)duration:(_Nullable YTDoubleCompletionHandler)completionHandler {
  [self evaluateJavaScript:@"player.getDuration();"
         completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
    if (!completionHandler) {
      return;
    }
    if (error) {
      completionHandler(-1, error);
      return;
    }
    if (!result || ![result isKindOfClass:[NSNumber class]]) {
      completionHandler(0, nil);
      return;
    }
    completionHandler([result doubleValue], nil);
  }];
}

- (void)videoUrl:(_Nullable YTURLCompletionHandler)completionHandler {
  [self evaluateJavaScript:@"player.getVideoUrl();"
         completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
    if (!completionHandler) {
      return;
    }
    if (error) {
      completionHandler(nil, error);
      return;
    }
    if (!result || ![result isKindOfClass:[NSString class]]) {
      completionHandler(nil, nil);
      return;
    }
    completionHandler([NSURL URLWithString:result], nil);
  }];
}

- (void)videoEmbedCode:(_Nullable YTStringCompletionHandler)completionHandler {
  [self evaluateJavaScript:@"player.getVideoEmbedCode();"
         completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
    if (!completionHandler) {
      return;
    }
    if (error) {
      completionHandler(nil, error);
      return;
    }
    if (!result || ![result isKindOfClass:[NSString class]]) {
      completionHandler(nil, nil);
      return;
    }
    completionHandler(result, nil);
  }];
}

#pragma mark - Playlist methods

- (void)playlist:(_Nullable YTArrayCompletionHandler)completionHandler {
  [self evaluateJavaScript:@"player.getPlaylist();"
         completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
    if (!completionHandler) {
      return;
    }
    if (error) {
      completionHandler(nil, error);
    }
    if (!result || ![result isKindOfClass:[NSArray class]]) {
      completionHandler(nil, nil);
      return;
    }
    completionHandler(result, nil);
  }];
}

- (void)playlistIndex:(_Nullable YTIntCompletionHandler)completionHandler {
  [self evaluateJavaScript:@"player.getPlaylistIndex();"
         completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
    if (!completionHandler) {
      return;
    }
    if (error) {
      completionHandler(-1, error);
      return;
    }
    if (!result || ![result isKindOfClass:[NSNumber class]]) {
      completionHandler(0, nil);
      return;
    }
    completionHandler([result intValue], nil);
  }];
}

#pragma mark - Playing a video in a playlist

- (void)nextVideo {
  [self evaluateJavaScript:@"player.nextVideo();"];
}

- (void)previousVideo {
  [self evaluateJavaScript:@"player.previousVideo();"];
}

- (void)playVideoAt:(int)index {
  NSString *command =
      [NSString stringWithFormat:@"player.playVideoAt(%@);", [NSNumber numberWithInt:index]];
  [self evaluateJavaScript:command];
}

#pragma mark - Helper methods

/**
 * Convert a quality value from NSString to the typed enum value.
 *
 * @param qualityString A string representing playback quality. Ex: "small", "medium", "hd1080".
 * @return An enum value representing the playback quality.
 */
+ (YTPlaybackQuality)playbackQualityForString:(NSString *)qualityString {
  YTPlaybackQuality quality = kYTPlaybackQualityUnknown;

  if ([qualityString isEqualToString:kYTPlaybackQualitySmallQuality]) {
    quality = kYTPlaybackQualitySmall;
  } else if ([qualityString isEqualToString:kYTPlaybackQualityMediumQuality]) {
    quality = kYTPlaybackQualityMedium;
  } else if ([qualityString isEqualToString:kYTPlaybackQualityLargeQuality]) {
    quality = kYTPlaybackQualityLarge;
  } else if ([qualityString isEqualToString:kYTPlaybackQualityHD720Quality]) {
    quality = kYTPlaybackQualityHD720;
  } else if ([qualityString isEqualToString:kYTPlaybackQualityHD1080Quality]) {
    quality = kYTPlaybackQualityHD1080;
  } else if ([qualityString isEqualToString:kYTPlaybackQualityHighResQuality]) {
    quality = kYTPlaybackQualityHighRes;
  } else if ([qualityString isEqualToString:kYTPlaybackQualityAutoQuality]) {
    quality = kYTPlaybackQualityAuto;
  }

  return quality;
}

/**
 * Convert a state value from NSString to the typed enum value.
 *
 * @param stateString A string representing player state. Ex: "-1", "0", "1".
 * @return An enum value representing the player state.
 */
+ (YTPlayerState)playerStateForString:(NSString *)stateString {
  YTPlayerState state = kYTPlayerStateUnknown;
  if ([stateString isEqualToString:kYTPlayerStateUnstartedCode]) {
    state = kYTPlayerStateUnstarted;
  } else if ([stateString isEqualToString:kYTPlayerStateEndedCode]) {
    state = kYTPlayerStateEnded;
  } else if ([stateString isEqualToString:kYTPlayerStatePlayingCode]) {
    state = kYTPlayerStatePlaying;
  } else if ([stateString isEqualToString:kYTPlayerStatePausedCode]) {
    state = kYTPlayerStatePaused;
  } else if ([stateString isEqualToString:kYTPlayerStateBufferingCode]) {
    state = kYTPlayerStateBuffering;
  } else if ([stateString isEqualToString:kYTPlayerStateCuedCode]) {
    state = kYTPlayerStateCued;
  }
  return state;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  NSURLRequest *request = navigationAction.request;
  if ([request.URL.scheme isEqual:@"ytplayer"]) {
    [self notifyDelegateOfYouTubeCallbackUrl:request.URL];
    decisionHandler(WKNavigationActionPolicyCancel);
    return;
  } else if ([request.URL.scheme isEqual: @"http"] || [request.URL.scheme isEqual:@"https"]) {
    if ([self handleHttpNavigationToUrl:request.URL]) {
      decisionHandler(WKNavigationActionPolicyAllow);
    } else {
      decisionHandler(WKNavigationActionPolicyCancel);
    }
    return;
  }
  decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
  if (self.initialLoadingView) {
    [self.initialLoadingView removeFromSuperview];
  }
}

#pragma mark - Private methods

- (NSURL *)originURL {
  if (!_originURL) {
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSString *stringURL = [[NSString stringWithFormat:@"http://%@", bundleId] lowercaseString];
    _originURL = [NSURL URLWithString:stringURL];
  }
  return _originURL;
}

/**
 * Private method to handle "navigation" to a callback URL of the format
 * ytplayer://action?data=someData
 * This is how the webview communicates with the containing Objective-C code.
 * Side effects of this method are that it calls methods on this class's delegate.
 *
 * @param url A URL of the format ytplayer://action?data=value.
 */
- (void)notifyDelegateOfYouTubeCallbackUrl:(NSURL *) url {
  NSString *action = url.host;

  // We know the query can only be of the format ytplayer://action?data=SOMEVALUE,
  // so we parse out the value.
  NSString *query = url.query;
  NSString *data;
  if (query) {
    data = [query componentsSeparatedByString:@"="][1];
  }

  if ([action isEqual:kYTPlayerCallbackOnReady]) {
    if (self.initialLoadingView) {
      [self.initialLoadingView removeFromSuperview];
    }
    if ([self.delegate respondsToSelector:@selector(playerViewDidBecomeReady:)]) {
      [self.delegate playerViewDidBecomeReady:self];
    }
  } else if ([action isEqual:kYTPlayerCallbackOnStateChange]) {
    if ([self.delegate respondsToSelector:@selector(playerView:didChangeToState:)]) {
      YTPlayerState state = [YTPlayerView playerStateForString:data];
      [self.delegate playerView:self didChangeToState:state];
    }
  } else if ([action isEqual:kYTPlayerCallbackOnPlaybackQualityChange]) {
    if ([self.delegate respondsToSelector:@selector(playerView:didChangeToQuality:)]) {
      YTPlaybackQuality quality = [YTPlayerView playbackQualityForString:data];
      [self.delegate playerView:self didChangeToQuality:quality];
    }
  } else if ([action isEqual:kYTPlayerCallbackOnError]) {
    if ([self.delegate respondsToSelector:@selector(playerView:receivedError:)]) {
      YTPlayerError error = kYTPlayerErrorUnknown;

      if ([data isEqual:kYTPlayerErrorInvalidParamErrorCode]) {
        error = kYTPlayerErrorInvalidParam;
      } else if ([data isEqual:kYTPlayerErrorHTML5ErrorCode]) {
        error = kYTPlayerErrorHTML5Error;
      } else if ([data isEqual:kYTPlayerErrorNotEmbeddableErrorCode] ||
                 [data isEqual:kYTPlayerErrorSameAsNotEmbeddableErrorCode]) {
        error = kYTPlayerErrorNotEmbeddable;
      } else if ([data isEqual:kYTPlayerErrorVideoNotFoundErrorCode] ||
                 [data isEqual:kYTPlayerErrorCannotFindVideoErrorCode]) {
        error = kYTPlayerErrorVideoNotFound;
      }

      [self.delegate playerView:self receivedError:error];
    }
  } else if ([action isEqualToString:kYTPlayerCallbackOnPlayTime]) {
    if ([self.delegate respondsToSelector:@selector(playerView:didPlayTime:)]) {
      float time = [data floatValue];
      [self.delegate playerView:self didPlayTime:time];
    }
  } else if ([action isEqualToString:kYTPlayerCallbackOnYouTubeIframeAPIFailedToLoad]) {
    if (self.initialLoadingView) {
      [self.initialLoadingView removeFromSuperview];
    }
  }
}

- (BOOL)handleHttpNavigationToUrl:(NSURL *)url {
  // When loading the webView for the first time, webView tries loading the originURL
  // since it is set as the webView.baseURL.
  // In that case we want to let it load itself in the webView instead of trying
  // to load it in a browser.
  if ([[url.host lowercaseString] isEqualToString:[self.originURL.host lowercaseString]]) {
    return YES;
  }
  // Usually this means the user has clicked on the YouTube logo or an error message in the
  // player. Most URLs should open in the browser. The only http(s) URL that should open in this
  // webview is the URL for the embed, which is of the format:
  //     http(s)://www.youtube.com/embed/[VIDEO ID]?[PARAMETERS]
  NSError *error = NULL;
  NSRegularExpression *ytRegex =
      [NSRegularExpression regularExpressionWithPattern:kYTPlayerEmbedUrlRegexPattern
                                                options:NSRegularExpressionCaseInsensitive
                                                  error:&error];
  NSTextCheckingResult *ytMatch =
      [ytRegex firstMatchInString:url.absoluteString
                        options:0
                          range:NSMakeRange(0, [url.absoluteString length])];
    
  NSRegularExpression *adRegex =
      [NSRegularExpression regularExpressionWithPattern:kYTPlayerAdUrlRegexPattern
                                                options:NSRegularExpressionCaseInsensitive
                                                  error:&error];
  NSTextCheckingResult *adMatch =
      [adRegex firstMatchInString:url.absoluteString
                        options:0
                          range:NSMakeRange(0, [url.absoluteString length])];
    
  NSRegularExpression *syndicationRegex =
      [NSRegularExpression regularExpressionWithPattern:kYTPlayerSyndicationRegexPattern
                                                options:NSRegularExpressionCaseInsensitive
                                                  error:&error];

  NSTextCheckingResult *syndicationMatch =
      [syndicationRegex firstMatchInString:url.absoluteString
                                   options:0
                                     range:NSMakeRange(0, [url.absoluteString length])];

  NSRegularExpression *oauthRegex =
      [NSRegularExpression regularExpressionWithPattern:kYTPlayerOAuthRegexPattern
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
  NSTextCheckingResult *oauthMatch =
    [oauthRegex firstMatchInString:url.absoluteString
                           options:0
                             range:NSMakeRange(0, [url.absoluteString length])];
    
  NSRegularExpression *staticProxyRegex =
    [NSRegularExpression regularExpressionWithPattern:kYTPlayerStaticProxyRegexPattern
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
  NSTextCheckingResult *staticProxyMatch =
    [staticProxyRegex firstMatchInString:url.absoluteString
                                  options:0
                                    range:NSMakeRange(0, [url.absoluteString length])];

  if (ytMatch || adMatch || oauthMatch || staticProxyMatch || syndicationMatch) {
    return YES;
  } else {
    [[UIApplication sharedApplication] openURL:url
                                       options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @NO}
                             completionHandler:nil];
    return NO;
  }
}


/**
 * Private helper method to load an iframe player with the given player parameters.
 *
 * @param additionalPlayerParams An NSDictionary of parameters in addition to required parameters
 *                               to instantiate the HTML5 player with. This differs depending on
 *                               whether a single video or playlist is being loaded.
 * @return YES if successful, NO if not.
 */
- (BOOL)loadWithPlayerParams:(NSDictionary *)additionalPlayerParams {
  NSDictionary *playerCallbacks = @{
        @"onReady" : @"onReady",
        @"onStateChange" : @"onStateChange",
        @"onPlaybackQualityChange" : @"onPlaybackQualityChange",
        @"onError" : @"onPlayerError"
  };
  NSMutableDictionary *playerParams = [[NSMutableDictionary alloc] init];
  if (additionalPlayerParams) {
    [playerParams addEntriesFromDictionary:additionalPlayerParams];
  }
  if (![playerParams objectForKey:@"height"]) {
    [playerParams setValue:@"100%" forKey:@"height"];
  }
  if (![playerParams objectForKey:@"width"]) {
    [playerParams setValue:@"100%" forKey:@"width"];
  }

  [playerParams setValue:playerCallbacks forKey:@"events"];
  
  NSMutableDictionary *playerVars = [[playerParams objectForKey:@"playerVars"] mutableCopy];
  if (!playerVars) {
    // playerVars must not be empty so we can render a '{}' in the output JSON
    playerVars = [NSMutableDictionary dictionary];
  }
  // We always want to ovewrite the origin to self.originURL, not just for
  // the webView.baseURL
  [playerVars setObject:self.originURL.absoluteString forKey:@"origin"];
  [playerParams setValue:playerVars forKey:@"playerVars"];

  // Remove the existing webview to reset any state
  [self.webView removeFromSuperview];
  _webView = [self createNewWebView];
  [self addSubview:self.webView];

  NSError *error = nil;
  NSString *path = [[NSBundle bundleForClass:[YTPlayerView class]] pathForResource:@"YTPlayerView-iframe-player"
                                                   ofType:@"html"
                                              inDirectory:@"Assets"];
    
  // in case of using Swift and embedded frameworks, resources included not in main bundle,
  // but in framework bundle
  if (!path) {
      path = [[[self class] frameworkBundle] pathForResource:@"YTPlayerView-iframe-player"
                                                     ofType:@"html"
                                                inDirectory:@"Assets"];
  }
    
  NSString *embedHTMLTemplate =
      [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];

  if (error) {
    NSLog(@"Received error rendering template: %@", error);
    return NO;
  }

  // Render the playerVars as a JSON dictionary.
  NSError *jsonRenderingError = nil;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:playerParams
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&jsonRenderingError];
  if (jsonRenderingError) {
    NSLog(@"Attempted configuration of player with invalid playerVars: %@ \tError: %@",
          playerParams,
          jsonRenderingError);
    return NO;
  }

  NSString *playerVarsJsonString =
      [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

  NSString *embedHTML = [NSString stringWithFormat:embedHTMLTemplate, playerVarsJsonString];

  [self.webView loadHTMLString:embedHTML baseURL: self.originURL];
  self.webView.navigationDelegate = self;

  if ([self.delegate respondsToSelector:@selector(playerViewPreferredInitialLoadingView:)]) {
    UIView *initialLoadingView = [self.delegate playerViewPreferredInitialLoadingView:self];
    if (initialLoadingView) {
      initialLoadingView.frame = self.bounds;
      initialLoadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      [self addSubview:initialLoadingView];
      self.initialLoadingView = initialLoadingView;
    }
  }
  
  return YES;
}

/**
 * Private method for cueing both cases of playlist ID and array of video IDs. Cueing
 * a playlist does not start playback.
 *
 * @param cueingString A JavaScript string representing an array, playlist ID or list of
 *                     video IDs to play with the playlist player.
 * @param index 0-index position of video to start playback on.
 * @param startSeconds Seconds after start of video to begin playback.
 */
- (void)cuePlaylist:(NSString *)cueingString
               index:(int)index
        startSeconds:(float)startSeconds {
  NSNumber *indexValue = [NSNumber numberWithInt:index];
  NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
  NSString *command = [NSString stringWithFormat:@"player.cuePlaylist(%@, %@, %@);",
      cueingString, indexValue, startSecondsValue];
  [self evaluateJavaScript:command];
}

/**
 * Private method for loading both cases of playlist ID and array of video IDs. Loading
 * a playlist automatically starts playback.
 *
 * @param cueingString A JavaScript string representing an array, playlist ID or list of
 *                     video IDs to play with the playlist player.
 * @param index 0-index position of video to start playback on.
 * @param startSeconds Seconds after start of video to begin playback.
 */
- (void)loadPlaylist:(NSString *)cueingString
               index:(int)index
        startSeconds:(float)startSeconds {
  NSNumber *indexValue = [NSNumber numberWithInt:index];
  NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
  NSString *command = [NSString stringWithFormat:@"player.loadPlaylist(%@, %@, %@);",
      cueingString, indexValue, startSecondsValue];
  [self evaluateJavaScript:command];
}

/**
 * Private helper method for converting an NSArray of video IDs into its JavaScript equivalent.
 *
 * @param videoIds An array of video ID strings to convert into JavaScript format.
 * @return A JavaScript array in String format containing video IDs.
 */
- (NSString *)stringFromVideoIdArray:(NSArray *)videoIds {
  NSMutableArray *formattedVideoIds = [[NSMutableArray alloc] init];

  for (id unformattedId in videoIds) {
    [formattedVideoIds addObject:[NSString stringWithFormat:@"'%@'", unformattedId]];
  }

  return [NSString stringWithFormat:@"[%@]", [formattedVideoIds componentsJoinedByString:@", "]];
}

/**
 * Private method for evaluating JavaScript in the webview.
 *
 * @param jsToExecute The JavaScript code in string format that we want to execute.
 */
- (void)evaluateJavaScript:(NSString *)jsToExecute {
  [self evaluateJavaScript:jsToExecute completionHandler:nil];
}

/**
 * Private method for evaluating JavaScript in the webview.
 *
 * @param jsToExecute The JavaScript code in string format that we want to execute.
 * @param completionHandler A block to invoke when script evaluation completes or fails.
 */
- (void)evaluateJavaScript:(NSString *)jsToExecute
         completionHandler:(void(^)(id _Nullable result, NSError *_Nullable error))completionHandler {
  [_webView evaluateJavaScript:jsToExecute
             completionHandler:^(id _Nullable result, NSError *_Nullable error) {
    if (!completionHandler) {
      return;
    }
    if (error) {
      completionHandler(nil, error);
      return;
    }
    if (!result || [result isKindOfClass:[NSNull class]]) {
      // we can consider this an empty result
      completionHandler(nil, nil);
      return;
    }

    completionHandler(result, nil);
  }];
}

/**
 * Private method to convert a Objective-C BOOL value to JS boolean value.
 *
 * @param boolValue Objective-C BOOL value.
 * @return JavaScript Boolean value, i.e. "true" or "false".
 */
- (NSString *)stringForJSBoolean:(BOOL)boolValue {
  return boolValue ? @"true" : @"false";
}

#pragma mark - Exposed for Testing

- (void)setWebView:(WKWebView *)webView {
  _webView = webView;
}

- (WKWebView *)createNewWebView {
  WKWebViewConfiguration *webViewConfiguration = [[WKWebViewConfiguration alloc] init];
  webViewConfiguration.allowsInlineMediaPlayback = YES;
  webViewConfiguration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
  WKWebView *webView = [[WKWebView alloc] initWithFrame:self.bounds
                                          configuration:webViewConfiguration];
  webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
  webView.scrollView.scrollEnabled = NO;
  webView.scrollView.bounces = NO;

  if ([self.delegate respondsToSelector:@selector(playerViewPreferredWebViewBackgroundColor:)]) {
    webView.backgroundColor = [self.delegate playerViewPreferredWebViewBackgroundColor:self];
    if (webView.backgroundColor == [UIColor clearColor]) {
      webView.opaque = NO;
    }
  }
  return webView;
}

- (void)removeWebView {
  [self.webView removeFromSuperview];
  self.webView = nil;
}

+ (NSBundle *)frameworkBundle {
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle bundleForClass:[self class]] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"Assets.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return frameworkBundle;
}

@end
