//
//  SSJDownLoadProgressButton.m
//  SuiShouJi
//
//  Created by ricky on 16/6/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDownLoadProgressButton.h"
@interface SSJDownLoadProgressButton()
@property(nonatomic, strong) UIView *downloadMaskView;
@end

@implementation SSJDownLoadProgressButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.downloadMaskView];
    }
    return self;
}

-(UIView *)downloadMaskView{
    if (!_downloadMaskView) {
        _downloadMaskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, self.height)];
        _downloadMaskView.backgroundColor = [UIColor ssj_colorWithHex:@""];
    }
    return _downloadMaskView;
}

-(void)setMaskColor:(NSString *)maskColor{
    _maskColor = maskColor;
    self.downloadMaskView.backgroundColor = [UIColor ssj_colorWithHex:_maskColor];
}

-(void)setDownloadProgress:(NSProgress *)downloadProgress{
    _downloadProgress = downloadProgress;
    if (_downloadProgress.fractionCompleted >= 0 && _downloadProgress.fractionCompleted <= 100) {
        self.downloadMaskView.hidden = NO;
        NSLog(@"%f",_downloadProgress.fractionCompleted);
        self.downloadMaskView.width = self.width * _downloadProgress.completedUnitCount / _downloadProgress.totalUnitCount;
    }else{
        self.downloadMaskView.width = 0;
        self.downloadMaskView.hidden = YES;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
