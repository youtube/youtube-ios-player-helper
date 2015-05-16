//
//  Lyric.m
//  youtube-player-ios-example
//
//  Created by BooBoo on 5/15/2558 BE.
//  Copyright (c) 2558 YouTube Developer Relations. All rights reserved.
//

#import "Lyric.h"

@implementation Lyric

@synthesize list_lyric;

- (id) init
{
    if(!self){
     self = [super init];
    }
    current_lyric_line = @"";
    current_translation_line = @"";
    current_karaoke_line = @"";
    
    return self;
}

- (void) searchDataWithTitle:(NSString*) title
                                    andArtist:(NSString*) artist
                               andDescription:(NSString*) description
                                      andType:(LyricType) type
                                      andLang:(NSString*) lang
{
    [self loadSampleLyricFromFileWithTitle:title];
    [self loadSampleKaraokeFromFileWithTitle:title];
    [self loadSampleTranslationFromFileWithTitle:title];

}

//- (NSMutableDictionary*) searchLyricWithTitle:(NSString*) title
//                       andArtist:(NSString*) artist
//                  andDescription:(NSString*) description
//                         andType:(LyricType) type
//                         andLang:(NSString*) lang
//{
//    [self loadSampleLyricFromFile];
//    return list_lyric;
//}
//
//- (NSMutableDictionary*) searchKaraokeWithTitle:(NSString*) title
//                                         andArtist:(NSString*) artist
//                                    andDescription:(NSString*) description
//                                           andType:(LyricType) type
//                                           andLang:(NSString*) lang
//{
//
//    [self loadSampleKaraokeFromFile];
//    return list_karaoke;
//}
//
//- (NSMutableDictionary*) searchTranslationWithTitle:(NSString*) title
//                                         andArtist:(NSString*) artist
//                                    andDescription:(NSString*) description
//                                           andType:(LyricType) type
//                                           andLang:(NSString*) lang
//{
//    [self loadSampleTranslationFromFile];
//    return list_translation;
//}

- (NSMutableDictionary*) searchLyricsFromServiceWithTitle:(NSString*) title
                                         andArtist:(NSString*) artist
                                    andDescription:(NSString*) description
                                           andType:(LyricType) type
                                           andLang:(NSString*) lang
{
    
    // TODO retrieve lyrics from service
    return list_lyric;
}

- (NSMutableDictionary*) searchTranslationFromServiceWithTitle:(NSString*) title
                                                andArtist:(NSString*) artist
                                           andDescription:(NSString*) description
                                                  andType:(LyricType) type
                                                  andLang:(NSString*) lang
{
    
    // TODO retrieve lyrics from service
    return list_translation;
}

- (NSMutableDictionary*) searchKaraokeFromServiceWithTitle:(NSString*) title
                                                     andArtist:(NSString*) artist
                                                andDescription:(NSString*) description
                                                       andType:(LyricType) type
                                                       andLang:(NSString*) lang
{
    
    // TODO retrieve lyrics from service
    return list_karaoke;
}

- (void) loadSampleLyricFromFileWithTitle:(NSString*) titleName
{
    [list_lyric removeAllObjects];
    if(list_lyric==NULL){
        list_lyric = [[NSMutableDictionary alloc] init];
    }

    NSString *filename = [NSString stringWithFormat:@"%@.lyric.en", titleName];

    NSString* pathToFile = [[NSBundle mainBundle] pathForResource:filename ofType:@"txt"];
    NSString* contentFile = @"";
    if(pathToFile){
        contentFile = [NSString stringWithContentsOfFile:pathToFile
                                                encoding:NSUTF8StringEncoding
                                                   error:nil];
    }
    if(contentFile!=NULL){
    //    NSArray *lines = [contentFile componentsSeparatedByString:@"\n"];
        NSMutableArray *lines = [[contentFile componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]] mutableCopy];
        for(NSString *line in lines){
            //NSLog(@"each line: %@", line);
            NSArray *lineInfo = [line componentsSeparatedByString:@"--"];
            if([lineInfo count] > 0 && ([lineInfo count] == 2)){
                //NSLog(@"--%@", [lineInfo objectAtIndex:0]);
                NSString *timeInfo = [NSString stringWithFormat:@"%@",[lineInfo objectAtIndex:0]];
                NSString *textInfo = [lineInfo objectAtIndex:1];
                [list_lyric setValue:textInfo forKey:timeInfo];
                NSLog(@"Saving Time(%@-%@)", timeInfo, textInfo);
            }
        }
    }
    
    //NSLog(@"%@", lines);
}

- (void) loadSampleKaraokeFromFileWithTitle:(NSString*) titleName
{
    
    [list_karaoke removeAllObjects];
    if(list_karaoke==NULL){
        list_karaoke = [[NSMutableDictionary alloc] init];
    }

    NSString *filename = [NSString stringWithFormat:@"%@.karaoke.en", titleName];
    
    NSString* pathToFile = [[NSBundle mainBundle] pathForResource:filename
                                                           ofType:@"txt"];
    NSString* contentFile = @"";
    if(pathToFile){
        contentFile = [NSString stringWithContentsOfFile:pathToFile
                                                encoding:NSUTF8StringEncoding
                                                   error:nil];
    }
    if(contentFile!=NULL){
        //    NSArray *lines = [contentFile componentsSeparatedByString:@"\n"];
        NSMutableArray *lines = [[contentFile componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]] mutableCopy];
        for(NSString *line in lines){
            //NSLog(@"each line: %@", line);
            NSArray *lineInfo = [line componentsSeparatedByString:@"--"];
            if([lineInfo count] > 0 && ([lineInfo count] == 2)){
                //NSLog(@"--%@", [lineInfo objectAtIndex:0]);
                NSString *timeInfo = [NSString stringWithFormat:@"%@",[lineInfo objectAtIndex:0]];
                NSString *textInfo = [lineInfo objectAtIndex:1];
                [list_karaoke setValue:textInfo forKey:timeInfo];
                NSLog(@"Saving Time(%@-%@)", timeInfo, textInfo);
            }
        }
    }
    
    //NSLog(@"%@", lines);
}

- (void) loadSampleTranslationFromFileWithTitle:(NSString*) titleName
{
 
    [list_translation removeAllObjects];
    if(list_translation==NULL){
        list_translation = [[NSMutableDictionary alloc] init];
    }
    
    NSString *filename = [NSString stringWithFormat:@"%@.translation.en", titleName];
    
    NSString* pathToFile = [[NSBundle mainBundle] pathForResource:@"Serendipity.translation.en" ofType:@"txt"];
    NSString* contentFile = @"";
    if(pathToFile){
        contentFile = [NSString stringWithContentsOfFile:pathToFile
                                                encoding:NSUTF8StringEncoding
                                                   error:nil];
    }
    if(contentFile!=NULL){
        //NSArray *lines = [contentFile componentsSeparatedByString:@"\n"];
        NSMutableArray *lines = [[contentFile componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]] mutableCopy];
        for(NSString *line in lines){
            //NSLog(@"each line: %@", line);
            NSArray *lineInfo = [line componentsSeparatedByString:@"--"];
            if([lineInfo count] > 0 && ([lineInfo count] == 2)){
                //NSLog(@"--%@", [lineInfo objectAtIndex:0]);
                NSString *timeInfo = [NSString stringWithFormat:@"%@",[lineInfo objectAtIndex:0]];
                NSString *textInfo = [lineInfo objectAtIndex:1];
                [list_translation setValue:textInfo forKey:timeInfo];
                NSLog(@"Saving Time(%@-%@)", timeInfo, textInfo);
            }
        }
    }
    
    //NSLog(@"%@", lines);
}


- (NSString*) retrieveTranslationInfoAtTime:(NSString*) atTime
{
    
    NSString *timeInfo = [NSString stringWithFormat:@"%@",atTime];
    if([list_translation count] > 0){
        //NSLog(@"Start search time at:%@", timeInfo);
        NSString *searchResult =  (NSString*)[list_translation objectForKey:timeInfo];
        NSLog(@"Search results:%@", searchResult);
        
        if(searchResult!=NULL){
            current_translation_line = searchResult;
        }
        NSLog(@"Current results:%@", current_translation_line);
    }
        
    return current_translation_line;
}

- (NSString*) retrieveKaraokeInfoAtTime:(NSString*) atTime
{
    
    NSString *timeInfo = [NSString stringWithFormat:@"%@",atTime];
    //NSLog(@"Start search time at:%@", timeInfo);
    if([list_karaoke count] > 0){
        NSString *searchResult =  (NSString*)[list_karaoke objectForKey:timeInfo];
        NSLog(@"Search results:%@", searchResult);
        
        if(searchResult!=NULL){
            current_karaoke_line = searchResult;
        }
        NSLog(@"Current results:%@", current_karaoke_line);
    }
    
    return current_karaoke_line;
}

- (NSString*) retrieveLyricInfoAtTime:(NSString*) atTime
{
    
    NSString *timeInfo = [NSString stringWithFormat:@"%@",atTime];
    //NSLog(@"Start search time at:%@", timeInfo);
    if([list_lyric count] > 0){
        NSString *searchResult =  (NSString*)[list_lyric objectForKey:timeInfo];
        NSLog(@"Search results:%@", searchResult);
        
        if(searchResult!=NULL){
            current_lyric_line = searchResult;
        }
        NSLog(@"Current results:%@", current_lyric_line);
    }
    
    return current_lyric_line;
}

@end
