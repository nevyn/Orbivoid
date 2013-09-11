#import <Foundation/Foundation.h>

@interface ORBHighscore : NSObject
@property(nonatomic) NSString *name;
@property(nonatomic) float score;
@end

extern NSString *const ORBHighscoresChangedNotification;

@interface ORBHighscoreController : NSObject
@property(nonatomic) NSString *playerName;
- (void)submitScore:(float)score forGameMode:(NSString*)gameMode;

- (NSArray/*<ORBHighscore>*/*)scoresInMode:(NSString*)gameMode;
@end
