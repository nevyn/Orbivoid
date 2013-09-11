#import "ORBHighscoreController.h"

NSString *const ORBHighscoresChangedNotification = @"ORBHighscoresChangedNotification";

@implementation ORBHighscoreController
{
    NSDictionary *_scores; // mode => [ORBHighscore]
}
- (id)init
{
    if(!(self = [super init]))
        return nil;
    
    [self fetchScores];
    
    return self;
}
- (void)submitScore:(float)score forGameMode:(NSString*)gameMode
{
    NSData *payload = [NSJSONSerialization dataWithJSONObject:@{
        @"mode": gameMode,
        @"user": _playerName,
        @"score": @(score),
    } options:0 error:NULL];
    NSURL *url = [NSURL URLWithString:@"http://nevyn.nu/orbivoid/highscores.php?submit"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPBody = payload;
    [req setValue:[NSString stringWithFormat:@"%d", payload.length] forKey:@"Content-Length"];
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:(id)^(NSHTTPURLResponse *response, NSData *data, NSError *connectionError) {
        if(!response || response.statusCode != 200 || connectionError) {
            NSLog(@"Failed submitting score!! %@ %@ %@", response, connectionError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            return;
        }
        
        [self fetchScores];
    }];
}

- (NSArray/*<ORBHighscore>*/*)scoresInMode:(NSString*)gameMode
{
    return _scores[gameMode];
}

- (void)fetchScores
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fetchScores) object:nil];
    
    NSURL *url = [NSURL URLWithString:@"http://nevyn.nu/orbivoid/highscores.php?get"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:(id)^(NSHTTPURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSError *parseError;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        
        if(!response || response.statusCode != 200 || connectionError || !json) {
            NSLog(@"Failed submitting score!! %@ %@ %@ %@", response, connectionError, parseError, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            return;
        }
        
        NSMutableDictionary *newScores = [NSMutableDictionary new];
        
        for(NSString *modeName in json[@"modes"]) {
            NSDictionary *modeDesc = json[@"modes"][modeName];
            NSMutableArray *scoresForMode = [NSMutableArray new];
            for(NSDictionary *score in modeDesc[@"scores"]) {
                ORBHighscore *highscore = [ORBHighscore new];
                highscore.name = score[@"player"];
                highscore.score = [score[@"score"] floatValue];
                [scoresForMode addObject:highscore];
            }
            newScores[modeName] = scoresForMode;
        }
        _scores = newScores;
        [[NSNotificationCenter defaultCenter] postNotificationName:ORBHighscoresChangedNotification object:self];
        [self performSelector:_cmd withObject:nil afterDelay:30];
    }];
}
@end

@implementation ORBHighscore

@end
