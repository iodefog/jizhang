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

@interface SSJBookkeepingTreeView ()

// 展示静态记账树图片
@property (nonatomic, strong) UIImageView *treeView;

// 记账树gif图片
@property (nonatomic, strong) FLAnimatedImageView *rainingView;

// 虚线边框
@property (nonatomic, strong) UIImageView *dashLineView;

// 用户昵称
@property (nonatomic, strong) NSString *nickName;

// 签到描述
@property (nonatomic, strong) UILabel *checkInDescLab;

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

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _treeView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_treeView];
        
        _rainingView = [[FLAnimatedImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_rainingView];
        
        _dashLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dash_border"]];
        [self addSubview:self.dashLineView];
        
        _checkInDescLab = [[UILabel alloc] init];
        _checkInDescLab.font = [UIFont systemFontOfSize:14];
        _checkInDescLab.textColor = [UIColor whiteColor];
        _checkInDescLab.textAlignment = NSTextAlignmentCenter;
        _checkInDescLab.numberOfLines = 0;
        [self addSubview:self.checkInDescLab];
        
        if (SSJIsUserLogined()) {
            SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"nickName"] forUserId:SSJUSERID()];
            _nickName = userItem.nickName;
        }
    }
    return self;
}

- (void)layoutSubviews {
    _treeView.frame = _rainingView.frame = self.bounds;
    _dashLineView.center = _checkInDescLab.center = CGPointMake(self.width * 0.5, self.height * 0.78);
}

- (void)setTreeImg:(UIImage *)treeImg {
    _treeView.image = treeImg;
}

- (void)setTreeGifData:(NSData *)treeGifData {
    _rainingView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:treeGifData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _rainingView.animatedImage = nil;
    });
}

- (void)setCheckTimes:(NSInteger)checkTimes {
    NSMutableString *desc = [@"Hi" mutableCopy];
    if (_nickName.length) {
        [desc appendFormat:@",%@~", _nickName];
    }
    [desc appendFormat:@"\n%@", [SSJBookkeepingTreeHelper descriptionForDays:checkTimes]];
    self.checkInDescLab.text = desc;
    [self.checkInDescLab sizeToFit];
    [self setNeedsLayout];
}

@end
