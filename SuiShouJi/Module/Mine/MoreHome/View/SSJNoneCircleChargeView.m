//
//  SSJNoneCircleChargeView.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNoneCircleChargeView.h"
@interface SSJNoneCircleChargeView()
@property (nonatomic,strong) UIImageView *noDataImage;
@property (nonatomic,strong) UILabel *noDataLabel;

@end
@implementation SSJNoneCircleChargeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.noDataImage];
        [self addSubview:self.noDataLabel];
    }
    return self;
}

-(void)layoutSubviews{
    self.noDataImage.size = CGSizeMake(181, 212);
    self.noDataImage.centerX = self.width / 2;
    self.noDataImage.top = 20;
    self.noDataLabel.top = self.noDataImage.bottom + 20;
    self.noDataLabel.centerX = self.width / 2;
}

-(UIImageView *)noDataImage{
    if (!_noDataImage) {
        _noDataImage = [[UIImageView alloc]init];
        _noDataImage.image = [UIImage imageNamed:@"zhouqi_none"];
    }
    return _noDataImage;
}

-(UILabel *)noDataLabel{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc]init];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.text = @"您暂未设置任何周期记账哦~";
        _noDataLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _noDataLabel.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
        [_noDataLabel sizeToFit];
    }
    return _noDataLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
