//
//  LyricLang.h
//  youtube-player-ios-example
//
//  Created by BooBoo on 5/16/2558 BE.
//  Copyright (c) 2558 YouTube Developer Relations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LyricLang : NSObject
{
    NSString *name_short;
    NSString *name_long;
    NSString *description;
}

@property(nonatomic, strong) NSString *name_short;
@property(nonatomic, strong) NSString *name_long;
@property(nonatomic, strong) NSString *description;

- (id) initWithName:(NSString*) name_short
        andLongName:(NSString*) name_long
     andDescription:(NSString*) description;

@end
