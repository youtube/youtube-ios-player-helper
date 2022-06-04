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

#import <TargetConditionals.h>

// -------------------- Imports ----------------------
#if TARGET_OS_OSX
    #import <AppKit/AppKit.h>
    #import "NSView+UIView.h"
#elif TARGET_OS_IOS
    #import <UIKit/UIKit.h>
    #import "UIView+NSView.h"
#endif

// -------------------- PlatformSpecific ---------------------
#if TARGET_OS_OSX
    #define YTView NSView
    #define YTColor NSColor
    #define YTViewAutoresizingFlexibleWidth NSViewWidthSizable
    #define YTViewAutoresizingFlexibleHeight NSViewHeightSizable
#elif TARGET_OS_IOS
    #define YTView UIView
    #define YTColor UIColor
    #define YTViewAutoresizingFlexibleWidth UIViewAutoresizingFlexibleWidth
    #define YTViewAutoresizingFlexibleHeight UIViewAutoresizingFlexibleHeight
#endif
