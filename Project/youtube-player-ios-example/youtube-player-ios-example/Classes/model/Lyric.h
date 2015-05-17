//
//  Lyric.h
//  youtube-player-ios-example
//
//  Created by BooBoo on 5/15/2558 BE.
//  Copyright (c) 2558 YouTube Developer Relations. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum:NSInteger {
    LyricOriginal = 0,
    LyricTranslation,
    LyricKarakoke,
    LyricSecret,
    LyricTypeCount
}LyricType;

@interface Lyric : NSObject
{
    NSMutableDictionary *list_lyric;
    NSMutableDictionary *list_karaoke;
    NSMutableDictionary *list_translation;
    NSMutableDictionary *list_secret;
    
    NSString* current_lyric_line;
    NSString* current_translation_line;
    NSString* current_karaoke_line;
    NSString* current_secret_line;
}

@property(nonatomic, strong) NSMutableDictionary *list_lyric;
@property(nonatomic, strong) NSString* current_lyric_line;
@property(nonatomic, strong) NSString* current_translation_line;
@property(nonatomic, strong) NSString* current_karaoke_line;
@property(nonatomic, strong) NSString* current_secret_line;

- (void) searchDataWithTitle:(NSString*) title
                   andArtist:(NSString*) artist
              andDescription:(NSString*) description
                     andType:(LyricType) type
                     andLang:(NSString*) lang;
//- (NSMutableDictionary*) searchLyricWithTitle:(NSString*) title
//                       andArtist:(NSString*) artist
//                    andDescription:(NSString*) description
//                         andType:(LyricType) type
//                         andLang:(NSString*) lang;
//- (NSMutableDictionary*) searchKaraokeWithTitle:(NSString*) title
//                                    andArtist:(NSString*) artist
//                               andDescription:(NSString*) description
//                                      andType:(LyricType) type
//                                        andLang:(NSString*) lang;
//- (NSMutableDictionary*) searchTranslationWithTitle:(NSString*) title
//                                    andArtist:(NSString*) artist
//                               andDescription:(NSString*) description
//                                      andType:(LyricType) type
//                                            andLang:(NSString*) lang;

- (NSString*) retrieveLyricInfoAtTime:(NSString*) atTime;
- (NSString*) retrieveTranslationInfoAtTime:(NSString*) atTime;
- (NSString*) retrieveKaraokeInfoAtTime:(NSString*) atTime;
- (NSString*) retrieveSecretInfoAtTime:(NSString*) atTime;

- (void) clearCurrentLyric;

@end
