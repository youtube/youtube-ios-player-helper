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

#import "NSView+UIView.h"

#if TARGET_OS_OSX

#import <AppKit/AppKit.h>

@implementation NSView (UIView)

- (NSColor *)platformBackgroundColor {
    return [NSColor colorWithCGColor:self.layer.backgroundColor];
}

- (void)setPlatformBackgroundColor:(NSColor *)platformBackgroundColor {
    self.wantsLayer = YES;
    self.layer.backgroundColor = platformBackgroundColor.CGColor;
}

- (BOOL)platformOpaque {
    return self.layer.opaque;
}

- (void)setPlatformOpaque:(BOOL)platformOpaque {
    self.wantsLayer = YES;
    self.layer.opaque = platformOpaque;
}

@end

#endif
