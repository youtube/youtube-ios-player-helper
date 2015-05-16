//
//  LyricLang.m
//  youtube-player-ios-example
//
//  Created by BooBoo on 5/16/2558 BE.
//  Copyright (c) 2558 YouTube Developer Relations. All rights reserved.
//

#import "LyricLang.h"

@implementation LyricLang

@synthesize name_short;
@synthesize name_long;
@synthesize description;

- (id) initWithName:(NSString*) _name_short
          andLongName:(NSString*) _name_long
       andDescription:(NSString*) _description
{
    if(!self){
        self = [super init];
    }
    self.name_short = _name_short;
    self.name_long = _name_long;
    self.description = _description;
    
    return self;
}

#pragma mark - Instance method


#pragma mark - Private method
@end
