//
//  ORBMenuScene.m
//  Orbivoid
//
//  Created by Joachim Bengtsson on 2013-09-01.
//  Copyright (c) 2013 Neto. All rights reserved.
//

#import "ORBMenuScene.h"
#import "ORBGameScene.h"
#import "SKEmitterNode+fromFile.h"
#import <objc/runtime.h>
#import "ORBGameScene.h"

static NSString *const ORBGameModeDefault = @"orbivoid.gamemode";

@interface ORBMenuScene () <UITableViewDataSource, UITableViewDelegate>
@end

@implementation ORBMenuScene
{
    UIButton *_modeButton;
    Class _currentMode;
    UITableViewController *_modeChooser;
}
- (instancetype)initWithSize:(CGSize)size
{
    if(self = [super initWithSize:size]) {
        SKEmitterNode *background = [SKEmitterNode orb_emitterNamed:@"Background"];
            background.particlePositionRange = CGVectorMake(self.size.width*2, self.size.height*2);
            [background advanceSimulationTime:10];
        
        [self addChild:background];
        
        SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Black"];
        
        title.text = @"Orbivoid";
        title.fontSize = 70;
        title.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        title.fontColor = [SKColor colorWithHue:0 saturation:0 brightness:1 alpha:1.0];
        
        [self addChild:title];
        
        SKLabelNode *tapToPlay = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Black"];
        
        tapToPlay.text = @"Tap to play";
        tapToPlay.fontSize = 40;
        tapToPlay.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame) - 80);
        tapToPlay.fontColor = [SKColor colorWithHue:0 saturation:0 brightness:1 alpha:0.7];
        [self addChild:tapToPlay];
        
        NSString *currentModeName = [[NSUserDefaults standardUserDefaults] stringForKey:ORBGameModeDefault];
        _currentMode = NSClassFromString(currentModeName);
        if(!_currentMode)
            _currentMode = [self availableGameScenes][0];
        
        _modeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _modeButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Black" size:40];
        [_modeButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
        _modeButton.frame = CGRectMake(0, (self.size.height - tapToPlay.position.y) + 20, self.size.width, 60);
        [self updateModeButton];
        [_modeButton addTarget:self action:@selector(selectMode) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)didMoveToView:(SKView *)view
{
    [view addSubview:_modeButton];
}
- (void)willMoveFromView:(SKView *)view;
{
    [_modeButton removeFromSuperview];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    ORBGameScene *game = [[_currentMode alloc] initWithSize:self.size];
    [self.view presentScene:game transition:[SKTransition doorsOpenHorizontalWithDuration:0.5]];
}

#pragma mark Modes

- (void)updateModeButton
{
    [_modeButton setTitle:[_currentMode modeName] forState:UIControlStateNormal];
}

- (void)selectMode
{
    _modeChooser = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    _modeChooser.tableView.delegate = self;
    _modeChooser.tableView.dataSource = self;
    _modeChooser.view.frame = CGRectMake(50, 50, self.size.width-100, self.size.height-100);
    [self.view addSubview:_modeChooser.view];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self availableGameScenes].count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    Class current = [self availableGameScenes][indexPath.row];
    cell.textLabel.text = [current modeName];
    if(current == _currentMode)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _currentMode = [self availableGameScenes][indexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject:NSStringFromClass(_currentMode) forKey:ORBGameModeDefault];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_modeChooser.view removeFromSuperview];
    [self updateModeButton];
}

- (NSArray*)availableGameScenes
{
    static NSMutableArray *gameSceneClasses;
    if(!gameSceneClasses) {
        gameSceneClasses = [NSMutableArray new];
        int count = objc_getClassList(NULL, 0);
        Class classes[count];
        objc_getClassList(classes, count);
        for(int i = 0; i < count; i++) {
            Class klass = class_getSuperclass(classes[i]);
            while(klass) {
                if(klass == [ORBGameScene class]) {
                    [gameSceneClasses addObject:classes[i]];
                    break;
                }
                klass = class_getSuperclass(klass);
            }
        }
    }
    return gameSceneClasses;
}


@end
