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

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import <WebKit/WebKit.h>

#import "YTPlayerView.h"

@interface youtube_player_ios_exampleTests : XCTestCase

@end

@interface YTPlayerView (ExposedForTesting)
- (void)setWebView:(WKWebView *)webView;
- (WKWebView *) createNewWebView;
@end

@implementation youtube_player_ios_exampleTests {
  YTPlayerView *playerView;
  id mockWebView;
  id mockDelegate;
}

- (void)setUp {
  [super setUp];
  playerView = [[YTPlayerView alloc] init];
  mockWebView = [OCMockObject mockForClass:[WKWebView class]];
  mockDelegate = [OCMockObject mockForProtocol:@protocol(YTPlayerViewDelegate)];
  playerView.delegate = mockDelegate;
  playerView.webView = mockWebView;
}

- (void)tearDown {
  [super tearDown];
}

#pragma mark - Player loading tests

- (void)testLoadPlayerVideoId {
  WKWebView *webView = [[WKWebView alloc] init];
  id partialWebViewMock = [OCMockObject partialMockForObject:webView];
  id partailPlayer = [self makePartialPlayerMockWithWebView:partialWebViewMock];

   [(WKWebView *)[partialWebViewMock expect] loadHTMLString:[OCMArg checkWithBlock:^BOOL(NSString *html) {
      if ([html rangeOfString:@"VIDEO_ID_HERE"].location == NSNotFound) {
        return NO;
      } else {
        return YES;
      }
  }]
                                      baseURL:[OCMArg any]];
  [partailPlayer loadWithVideoId:@"VIDEO_ID_HERE"];
  [partialWebViewMock verify];
}

- (void)testLoadPlayerPlaylistId {
  WKWebView *webView = [[WKWebView alloc] init];
  id partialWebViewMock = [OCMockObject partialMockForObject:webView];
  id partialPlayer = [self makePartialPlayerMockWithWebView:partialWebViewMock];
  
  [(WKWebView *)[partialWebViewMock expect] loadHTMLString:[OCMArg checkWithBlock:^BOOL(NSString *html) {
      // There are two strings to check for:
      //     "list" : "PLAYLIST_ID_HERE"
      // and
      //     "listType" : "playlist"
      NSString *expectedPlaylistId = @"\"list\" : \"PLAYLIST_ID_HERE\"";
      NSString *expectedListType = @"\"listType\" : \"playlist\"";
      if ([html rangeOfString:expectedPlaylistId].location == NSNotFound) {
        return NO;
      }
      if ([html rangeOfString:expectedListType].location == NSNotFound) {
        return NO;
      }
      return YES;
  }]
                                      baseURL:[OCMArg any]];
  [partialPlayer loadWithPlaylistId:@"PLAYLIST_ID_HERE"];
  [partialWebViewMock verify];
}

- (void)testLoadPlayerPlayerParameters {
  WKWebView *webView = [[WKWebView alloc] init];
  id partialWebViewMock = [OCMockObject partialMockForObject:webView];
  id partialPlayer = [self makePartialPlayerMockWithWebView:partialWebViewMock];

  [(WKWebView *)[partialWebViewMock expect] loadHTMLString:[OCMArg checkWithBlock:^BOOL(NSString *html) {
      if ([html rangeOfString:@"\"RANDOM_PARAMETER\" : 1"].location == NSNotFound) {
        return NO;
      } else {
        return YES;
      }
  }]
                                      baseURL:[OCMArg any]];
  [partialPlayer loadWithVideoId:@"VIDEO_ID_HERE" playerVars:@{ @"RANDOM_PARAMETER" : @1 }];
  [partialWebViewMock verify];
}

- (id)makePartialPlayerMockWithWebView:(WKWebView *)webView {
  id partialPlayer = [OCMockObject partialMockForObject:playerView];
  OCMStub([partialPlayer webView]).andReturn(webView);
  OCMStub([partialPlayer createNewWebView]).andReturn(webView);
  OCMStub([partialPlayer addSubview:[OCMArg isNotNil]]).andDo(nil);
  OCMStub([partialPlayer delegate]).andReturn(nil);

  return partialPlayer;
}

#pragma mark - Player Controls

- (void)testPlayVideo {
  [[mockWebView expect] evaluateJavaScript:@"player.playVideo();" completionHandler:[OCMArg any]];
  [playerView playVideo];
  [mockWebView verify];
}

- (void)testPauseVideo {
  [[mockDelegate expect] playerView:playerView didChangeToState:kYTPlayerStatePaused];
  [[mockWebView expect] evaluateJavaScript:@"player.pauseVideo();" completionHandler:[OCMArg any]];
  [playerView pauseVideo];
  [mockWebView verify];
}

- (void)testStopVideo {
  [[mockWebView expect] evaluateJavaScript:@"player.stopVideo();" completionHandler:[OCMArg any]];
  [playerView stopVideo];
  [mockWebView verify];
}

- (void)testSeekTo {
  [[mockWebView expect] evaluateJavaScript:@"player.seekTo(5.5, false);" completionHandler:[OCMArg any]];
  [playerView seekToSeconds:5.5 allowSeekAhead:NO];
  [mockWebView verify];
}

#pragma mark - Tests for cueing and loading videos

- (void)testCueVideoByIdstartSeconds {
  [[mockWebView expect] evaluateJavaScript:@"player.cueVideoById('abc', 5.5);"
                         completionHandler:[OCMArg any]];
  
  [playerView cueVideoById:@"abc" startSeconds:5.5];
  [mockWebView verify];
}

- (void)testCueVideoByIdstartSecondsendSecondsWithQuality {
  [[mockWebView expect] evaluateJavaScript:@"player.cueVideoById({'videoId': 'abc','startSeconds': 5.5, 'endSeconds': 10.5});"
                         completionHandler:[OCMArg any]];
  [playerView cueVideoById:@"abc"
              startSeconds:5.5
                endSeconds:10.5];
  [mockWebView verify];
}

- (void)testLoadVideoByIdstartSeconds {
  [[mockWebView expect] evaluateJavaScript:@"player.loadVideoById('abc', 5.5);"
                         completionHandler:[OCMArg any]];
  [playerView loadVideoById:@"abc" startSeconds:5.5];
  [mockWebView verify];
}

- (void)testCueVideoByUrlstartSecondsWithQuality {
  [[mockWebView expect] evaluateJavaScript:
   @"player.cueVideoByUrl('http://www.youtube.com/watch?v=J0tafinyviA', 5.5);"
                         completionHandler:[OCMArg any]];
  [playerView cueVideoByURL:@"http://www.youtube.com/watch?v=J0tafinyviA"
               startSeconds:5.5];
  [mockWebView verify];
}

- (void)testCueVideoByUrlstartSecondsendSecondsWithQuality {
  [[mockWebView expect]
   evaluateJavaScript:@"player.cueVideoByUrl('http://www.youtube.com/"
   "watch?v=J0tafinyviA', 5.5, 10.5);" completionHandler:[OCMArg any]];
  [playerView cueVideoByURL:@"http://www.youtube.com/watch?v=J0tafinyviA"
               startSeconds:5.5
                 endSeconds:10.5];
  [mockWebView verify];
}

- (void)testLoadVideoByUrlstartSecondsWithQuality {
  [[mockWebView expect] evaluateJavaScript:
   @"player.loadVideoByUrl('http://www.youtube.com/watch?v=J0tafinyviA', 5.5);" completionHandler:[OCMArg any]];
  [playerView loadVideoByURL:@"http://www.youtube.com/watch?v=J0tafinyviA"
                startSeconds:5.5];
  [mockWebView verify];
}

- (void)testLoadVideoByUrlstartSecondsendSecondsWithQuality {
  [[mockWebView expect]
   evaluateJavaScript:@"player.cueVideoByUrl('http://www.youtube.com/"
   "watch?v=J0tafinyviA', 5.5, 10.5);" completionHandler:[OCMArg any]];
  [playerView cueVideoByURL:@"http://www.youtube.com/watch?v=J0tafinyviA"
               startSeconds:5.5
                 endSeconds:10.5];
  [mockWebView verify];
}

#pragma mark - Tests for cueing and loading playlists

- (void)testCuePlaylistIdIndexStartSecondsWithSuggestedQuality {
  [[mockWebView expect] evaluateJavaScript:@"player.cuePlaylist('abc', 2, 10.5);" completionHandler:[OCMArg any]];
  [playerView cuePlaylistByPlaylistId:@"abc"
                                index:2
                         startSeconds:10.5];
  [mockWebView verify];
}

- (void)testCuePlaylistWithListOfVideoIds {

  [[mockWebView expect] evaluateJavaScript:
   @"player.cuePlaylist(['abc', 'def'], 2, 10.5);" completionHandler:[OCMArg any]];

  NSArray *videoIds = @[ @"abc", @"def" ];
  [playerView cuePlaylistByVideos:videoIds
                            index:2
                     startSeconds:10.5];

  [mockWebView verify];
}

#pragma mark - Retrieving playlist information

- (void)testGetPlaylist {
  // The key test here is seeing if we can correctly convert a JavaScript
  // array into an NSArray of NSString instances
  XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
  
  [[mockWebView stub]
   evaluateJavaScript:@"player.getPlaylist();" completionHandler:[OCMArg invokeBlockWithArgs:@[@"abc", @"def", @"xyz"], NSNull.null, nil]];

  NSArray *expectedArray = @[ @"abc", @"def", @"xyz" ];
  
  [playerView playlist:^(NSArray * _Nullable result, NSError * _Nullable error) {
    XCTAssertEqualObjects(expectedArray, result, @"Arrays are not equal.");
    [expectation fulfill];
  }];

  [self waitForExpectations:@[expectation] timeout:1.0];
}

#pragma mark - Callback tests

- (void)testOnPlayerReadyCallback {
  NSURL *url = [[NSURL alloc] initWithString:@"ytplayer://onReady"];
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
  
  id actionMock = [OCMockObject mockForClass:[WKNavigationAction class]];
  OCMStub([actionMock request]).andReturn(request);

  [[mockDelegate expect] playerViewDidBecomeReady:[OCMArg any]];
  [[mockDelegate stub] playerViewDidBecomeReady:[OCMArg any]];

  [(id<WKNavigationDelegate>) playerView webView:mockWebView decidePolicyForNavigationAction:actionMock decisionHandler:^(WKNavigationActionPolicy decision) {}];
  [mockDelegate verify];
}

- (void)testOnPlayerStateChangeCallback {
  NSURL *url = [[NSURL alloc] initWithString:@"ytplayer://onStateChange?data=1"];
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
  
  id actionMock = [OCMockObject mockForClass:[WKNavigationAction class]];
  OCMStub([actionMock request]).andReturn(request);

  [[mockDelegate expect] playerView:[OCMArg any] didChangeToState:kYTPlayerStatePlaying];

  [(id<WKNavigationDelegate>) playerView webView:mockWebView decidePolicyForNavigationAction:actionMock decisionHandler:^(WKNavigationActionPolicy decision) {}];
  
  [mockDelegate verify];
}

- (void)testOnPlaybackQualityChangeCallback {
  NSURL *url = [[NSURL alloc] initWithString:@"ytplayer://onPlaybackQualityChange?data=hd1080"];
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
  
  id actionMock = [OCMockObject mockForClass:[WKNavigationAction class]];
  OCMStub([actionMock request]).andReturn(request);

  [[mockDelegate expect] playerView:[OCMArg any] didChangeToQuality:kYTPlaybackQualityHD1080];

  [(id<WKNavigationDelegate>) playerView webView:mockWebView decidePolicyForNavigationAction:actionMock decisionHandler:^(WKNavigationActionPolicy decision) {}];
  
  [mockDelegate verify];
}

- (void)testOnErrorCallback {
  NSURL *url = [[NSURL alloc] initWithString:@"ytplayer://onError?data=101"];
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
  
  id actionMock = [OCMockObject mockForClass:[WKNavigationAction class]];
  OCMStub([actionMock request]).andReturn(request);

  [[mockDelegate expect] playerView:[OCMArg any] receivedError:kYTPlayerErrorNotEmbeddable];

  [(id<WKNavigationDelegate>) playerView webView:mockWebView decidePolicyForNavigationAction:actionMock decisionHandler:^(WKNavigationActionPolicy decision) {}];

  [mockDelegate verify];
}

- (void)testGetAvailablePlaybackRates {
  XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];

  [[mockWebView stub] evaluateJavaScript:@"player.getAvailablePlaybackRates();"
                       completionHandler:[OCMArg invokeBlockWithArgs:@[@0.25, @0.5, @1, @1.5, @2], NSNull.null, nil]];

  NSArray *expectedArray = @[ @0.25, @0.5, @1, @1.5, @2 ];
  
  [playerView availablePlaybackRates:^(NSArray * _Nullable result, NSError * _Nullable error) {
    XCTAssertEqualObjects(result, expectedArray, @"Arrays are not equal.");
    [expectation fulfill];
  }];
  
  [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGetVideoUrl {
  XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];

  NSURL *expectedURL = [NSURL URLWithString:@"http://www.youtube.com/watch?v=9moAdEslwkg"];
  [[mockWebView stub] evaluateJavaScript:@"player.getVideoUrl();"
                       completionHandler:[OCMArg invokeBlockWithArgs:@"http://www.youtube.com/watch?v=9moAdEslwkg", NSNull.null, nil]];
  
  
  [playerView videoUrl:^(NSURL * _Nullable result, NSError * _Nullable error) {
    XCTAssert([expectedURL isEqual:result]);
    [expectation fulfill];
  }];
  
  [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGetVideoEmbedCode {
  XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];

  NSString *expectedEmbedCode =
  @"<iframe width=\"560\" height=\"315\" src=\"//www.youtube.com/embed/9moAdEslwkg\" "
  "frameborder=\"0\" allowfullscreen></iframe>";
  [[mockWebView stub] evaluateJavaScript:@"player.getVideoEmbedCode();"
                       completionHandler:[OCMArg invokeBlockWithArgs:@"<iframe width=\"560\" height=\"315\" src=\"//www.youtube.com/embed/9moAdEslwkg\" "
                                          "frameborder=\"0\" allowfullscreen></iframe>", NSNull.null, nil]];
  
  [playerView videoEmbedCode:^(NSString * _Nullable result, NSError * _Nullable error) {
    XCTAssertEqual(expectedEmbedCode, result);
    [expectation fulfill];
  }];
  
  [self waitForExpectations:@[expectation] timeout:1.0];
}

#pragma mark - Testing catching non-embed URLs

- (void)testCatchingEmbedUrls {
  NSURL *youTubeEmbed =
  [NSURL URLWithString:@"https://www.youtube.com/embed/M7lc1UVf-VE?showinfo=0"];
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:youTubeEmbed];
  
  id actionMock = [OCMockObject mockForClass:[WKNavigationAction class]];
  OCMStub([actionMock request]).andReturn(request);

  // Application should NOT open the browser to the embed URL
  id mockApplication = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
  [[mockApplication reject] openURL:youTubeEmbed options:[OCMArg any] completionHandler:[OCMArg any]];

  [(id<WKNavigationDelegate>) playerView webView:mockWebView decidePolicyForNavigationAction:actionMock decisionHandler:^(WKNavigationActionPolicy decision) {
    XCTAssertEqual(WKNavigationActionPolicyAllow, decision, @"UIWebView should navigate to embed URL without opening browser");
  }];

  [mockApplication verify];
  [mockApplication stopMocking];
}

- (void)testCatchingNonEmbedUrls {
  NSURL *supportUrl =
  [NSURL URLWithString:@"https://support.google.com/youtube/answer/3037019?p=player_error1&rd=1"];
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:supportUrl];
  
  id actionMock = [OCMockObject mockForClass:[WKNavigationAction class]];
  OCMStub([actionMock request]).andReturn(request);

  id mockApplication = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
  [[mockApplication expect] openURL:supportUrl options:[OCMArg any] completionHandler:[OCMArg any]];
  
  [(id<WKNavigationDelegate>) playerView webView:mockWebView decidePolicyForNavigationAction:actionMock decisionHandler:^(WKNavigationActionPolicy decision) {
    XCTAssertEqual(WKNavigationActionPolicyCancel, decision, @"UIWebView should navigate to embed URL without opening browser");
  }];

  [mockApplication verify];
  [mockApplication stopMocking];
}

@end
