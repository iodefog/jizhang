//
//  SSJBookkeepingTreeView.m
//  SuiShouJi
//
//  Created by old lang on 16/4/15.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookkeepingTreeView.h"
#import "SSJBookkeepingTreeHelper.h"
#import "FLAnimatedImage.h"
#import "SSJBookkeepingTreeCheckInModel.h"
#import "SDWebImageManager.h"
#import "AFNetworking.h"
#import "SSJUserTableManager.h"
#import <AVFoundation/AVFoundation.h>

static const NSTimeInterval kRaninDuration = 3;

@interface SSJBookkeepingTreeView ()

// 展示静态记账树图片
@property (nonatomic, strong) UIImageView *treeView;

// 记账树gif图片
@property (nonatomic, strong) FLAnimatedImageView *rainingView;

// 虚线边框
@property (nonatomic, strong) UIImageView *dashLineView;

// 用户昵称
@property (nonatomic, strong) NSString *userName;

// 签到描述
@property (nonatomic, strong) UILabel *checkInDescLab;

// 静音按钮，按钮选中状态下就是静音
@property (nonatomic, strong) UIButton *muteButton;

@property (nonatomic, strong) AVAudioPlayer *player;

@end

@implementation SSJBookkeepingTreeView

- (NSCache *)memoryCache {
    static NSCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!cache) {
            cache = [[NSCache alloc] init];
        }
    });
    return cache;
}

- (void)dealloc {
    [_player stop];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _treeView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_treeView];
        
        _rainingView = [[FLAnimatedImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_rainingView];
        
        _dashLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dash_border"]];
        [self addSubview:self.dashLineView];
        
        _checkInDescLab = [[UILabel alloc] init];
        _checkInDescLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _checkInDescLab.textColor = [UIColor whiteColor];
        _checkInDescLab.textAlignment = NSTextAlignmentCenter;
        _checkInDescLab.numberOfLines = 0;
        [self addSubview:self.checkInDescLab];
        
        if (SSJIsUserLogined()) {
            [SSJUserTableManager queryProperty:@[@"nickName", @"mobileNo"] forUserId:SSJUSERID() success:^(SSJUserItem * _Nonnull userModel) {
                _userName = userModel.nickName;
                if (!_userName.length) {
                    if (userModel.mobileNo.length >= 7) {
                        _userName = [userModel.mobileNo stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                    }
                }
            } failure:^(NSError * _Nonnull error) {
                [SSJAlertViewAdapter showError:error];
            }];
        }
        
        _muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_muteButton setImage:[UIImage imageNamed:@"rain_sound_on"] forState:UIControlStateNormal];
        [_muteButton setImage:[UIImage imageNamed:@"rain_sound_on"] forState:(UIControlStateNormal | UIControlStateHighlighted)];
        [_muteButton setImage:[UIImage imageNamed:@"rain_sound_off"] forState:UIControlStateSelected];
        [_muteButton setImage:[UIImage imageNamed:@"rain_sound_off"] forState:(UIControlStateSelected | UIControlStateHighlighted)];
        [_muteButton addTarget:self action:@selector(muteButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_muteButton];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"rain_sound" ofType:@"wav"];
        if (path) {
            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:path] error:nil];
            if (_player.duration < kRaninDuration) {
                _player.numberOfLoops = -1;
            }
        }
    }
    return self;
}

- (void)layoutSubviews {
    _treeView.frame = _rainingView.frame = self.bounds;
    _dashLineView.center = _checkInDescLab.center = CGPointMake(self.width * 0.5, self.height * 0.78);
    _muteButton.frame = CGRectMake(self.width - 65, 120, 30, 30);
}

- (void)muteButtonAction {
    _muteButton.selected = !_muteButton.selected;
    _player.volume = _muteButton.selected ? 0 : 1;
}

- (void)setMute:(BOOL)mute {
    _player.volume = mute ? 0 : 1;
    _muteButton.selected = mute;
}

- (void)setMuteButtonShowed:(BOOL)showed {
    _muteButton.hidden = !showed;
}

- (void)setTreeImg:(UIImage *)treeImg {
    _treeView.image = treeImg;
}

- (void)startRainWithGifData:(NSData *)data completion:(void (^)())completion {
    if (!_player.playing) {
        [_player play];
    }
    _rainingView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRaninDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_player stop];
        _rainingView.animatedImage = nil;
        if (completion) {
            completion();
        }
    });
}

- (void)setCheckTimes:(NSInteger)checkTimes {
    NSMutableString *desc = [@"Hi" mutableCopy];
    if (_userName.length) {
        [desc appendFormat:@",%@~", _userName];
    }
    [desc appendFormat:@"\n%@", [self descriptionForDays:checkTimes]];
    self.checkInDescLab.text = desc;
    [self.checkInDescLab sizeToFit];
    [self setNeedsLayout];
}

- (NSString *)descriptionForDays:(NSInteger)days {
    SSJBookkeepingTreeLevel level = [SSJBookkeepingTreeHelper treeLevelForDays:days];
    if (level == SSJBookkeepingTreeLevelCrownTree) {
        return [NSString stringWithFormat:@"您的记账树已成长%ld天了,\n终于成顶级皇冠树了。", (long)days];
    } else {
        NSInteger daysToUpgrade = [SSJBookkeepingTreeHelper maxDaysForLevel:level] - days;
        NSString *nextLevel = [SSJBookkeepingTreeHelper treeLevelNameForLevel:level + 1];
        if (daysToUpgrade == 0) {
            return [NSString stringWithFormat:@"您的记账树已成长%ld天了,\n明天就可以长成%@啦。", (long)days, nextLevel];
        } else {
            return [NSString stringWithFormat:@"您的记账树已成长%ld天了,\n还有%ld天就可以长成%@啦。", (long)days, (long)daysToUpgrade, nextLevel];
        }
    }
}

@end
