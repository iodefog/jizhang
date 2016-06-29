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
        [self addSubview:self.button];
        [self addSubview:self.downloadMaskView];
    }
    return self;
}

-(UIView *)downloadMaskView{
    if (!_downloadMaskView) {
        _downloadMaskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, self.height)];
    }
    return _downloadMaskView;
}

-(UIButton *)button{
    if (!_button) {
        _button = [[UIButton alloc]initWithFrame:self.bounds];
    }
    return _button;
}

-(void)setMaskColor:(NSString *)maskColor{
    _maskColor = maskColor;
    self.downloadMaskView.backgroundColor = [UIColor ssj_colorWithHex:_maskColor];
}

-(void)setDownloadProgress:(float)downloadProgress{
    _downloadProgress = downloadProgress;
    if (_downloadProgress > 0 && _downloadProgress < 1) {
        self.downloadMaskView.width = self.width * _downloadProgress;
    }else{
        self.downloadMaskView.width = 0;
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
