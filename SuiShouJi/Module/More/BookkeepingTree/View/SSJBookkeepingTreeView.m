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

@property (nonatomic, strong) UIImageView *treeView;

@property (nonatomic, strong) FLAnimatedImageView *rainingView;

// 虚线边框
@property (nonatomic, strong) UIImageView *dashLineView;

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
        _checkInDescLab.textColor = [UIColor blackColor];
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

- (void)setCheckInModel:(SSJBookkeepingTreeCheckInModel *)checkInModel {
    [self setCheckInModel:checkInModel finishLoad:NULL];
}

- (void)setCheckInModel:(SSJBookkeepingTreeCheckInModel *)model finishLoad:(void(^)())finish {
    _checkInModel = model;
    
    NSURL *url = [NSURL URLWithString:SSJImageURLWithAPI(_checkInModel.treeImgUrl)];
    [_treeView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (finish) {
            finish();
        }
    }];
    
    NSString *gifUrl = SSJImageURLWithAPI(_checkInModel.treeGifUrl);
    [[AFHTTPSessionManager manager] GET:gifUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            [[self memoryCache] setObject:responseObject forKey:_checkInModel.treeGifUrl];
            [responseObject writeToFile:[self gifPath] atomically:YES];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
    NSMutableString *desc = [@"Hi" mutableCopy];
    if (_nickName.length) {
        [desc appendFormat:@",%@~", _nickName];
    }
    [desc appendFormat:@"\n%@", [SSJBookkeepingTreeHelper descriptionForDays:_checkInModel.checkInTimes]];
    self.checkInDescLab.text = desc;
    [self.checkInDescLab sizeToFit];
    
    [self setNeedsLayout];
}

- (void)startRainning {
    if (!_checkInModel || !_checkInModel.treeGifUrl.length) {
        return;
    }
    
    NSData *gifData = [[self memoryCache] objectForKey:_checkInModel.treeGifUrl];
    if (gifData) {
        [self showGifImageWithData:gifData];
        return;
    }
    
    gifData = [NSData dataWithContentsOfFile:[self gifPath]];
    if (gifData) {
        [self showGifImageWithData:gifData];
        return;
    }
}

- (NSString *)gifPath {
    NSString *documentPath = SSJDocumentPath();
    NSString *directoryPath = [documentPath stringByAppendingPathComponent:@"gif_tree"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            return @"";
        }
    }
    
    NSString *fileName = [_checkInModel.treeImgUrl lastPathComponent];
    if (![[fileName pathExtension] isEqualToString:@"gif"]) {
        return @"";
    }
    
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
    return filePath;
}

- (void)showGifImageWithData:(NSData *)data {
    _rainingView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _rainingView.animatedImage = nil;
    });
}

@end
