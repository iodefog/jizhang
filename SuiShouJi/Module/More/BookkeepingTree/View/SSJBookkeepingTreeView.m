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

// 下载gif图片最大失败重试次数
static const NSInteger kDownloadGifMaxFailureTimes = 3;

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

// 下载gif图片失败的次数，每次下载时清零
@property (nonatomic) NSInteger downloadGifFailureTimes;

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
    _downloadGifFailureTimes = 0;
    
    NSURL *url = [NSURL URLWithString:SSJImageURLWithAPI(_checkInModel.treeImgUrl)];
    [_treeView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (finish) {
            finish();
        }
    }];
    
    NSMutableString *desc = [@"Hi" mutableCopy];
    if (_nickName.length) {
        [desc appendFormat:@",%@~", _nickName];
    }
    [desc appendFormat:@"\n%@", [SSJBookkeepingTreeHelper descriptionForDays:_checkInModel.checkInTimes]];
    self.checkInDescLab.text = desc;
    [self.checkInDescLab sizeToFit];
    
    [self downloadGifImg];
    
    [self setNeedsLayout];
}

- (void)downloadGifImg {
    if ([self loadFromCache]) {
        return;
    }
    
    if (_downloadGifFailureTimes <= kDownloadGifMaxFailureTimes) {
        NSString *gifUrl = SSJImageURLWithAPI(_checkInModel.treeGifUrl);
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:gifUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([responseObject isKindOfClass:[NSData class]]) {
                [[self memoryCache] setObject:responseObject forKey:_checkInModel.treeGifUrl];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [responseObject writeToFile:[self gifDiskPath] atomically:YES];
                });
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            _downloadGifFailureTimes ++;
            [self downloadGifImg];
        }];
    }
}

- (void)startRainning {
    if (!_checkInModel || !_checkInModel.treeGifUrl.length) {
        return;
    }
    
    NSData *gifData = [self loadFromCache];
    if (gifData) {
        _rainingView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:gifData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _rainingView.animatedImage = nil;
        });
        return;
    }
}

- (NSData *)loadFromCache {
    NSData *gifData = [[self memoryCache] objectForKey:_checkInModel.treeGifUrl];
    if (gifData) {
        return gifData;
    }
    
    gifData = [NSData dataWithContentsOfFile:[self gifDiskPath]];
    if (gifData) {
        return gifData;
    }
    
    return nil;
}

- (NSString *)gifDiskPath {
    NSString *documentPath = SSJDocumentPath();
    NSString *directoryPath = [documentPath stringByAppendingPathComponent:@"gif_tree"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            return @"";
        }
    }
    
    NSString *fileName = [_checkInModel.treeGifUrl lastPathComponent];
    if (![[fileName pathExtension] isEqualToString:@"gif"]) {
        return @"";
    }
    
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
    return filePath;
}

@end
