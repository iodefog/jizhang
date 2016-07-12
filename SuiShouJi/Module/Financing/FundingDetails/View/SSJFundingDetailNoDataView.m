//
//  SSJFundingDetailNoDataView.m
//  SuiShouJi
//
//  Created by ricky on 16/7/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingDetailNoDataView.h"

@interface SSJFundingDetailNoDataView()
@property(nonatomic, strong) UIImageView *noDataImage;
@property(nonatomic, strong) UILabel *noDataLabel;
@end

@implementation SSJFundingDetailNoDataView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self addSubview:self.noDataImage];
        [self addSubview:self.noDataLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.noDataImage.centerX = self.width / 2;
    self.noDataImage.centerY = self.height / 2 - 5;
    self.noDataLabel.top = self.noDataImage.bottom + 10;
    self.noDataLabel.centerX = self.width / 2;
}

-(UIImageView *)noDataImage{
    if (!_noDataImage) {
        _noDataImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 150, 175)];
        _noDataImage.image = [UIImage imageNamed:@"zhouqi_none"];
    }
    return _noDataImage;
}

-(UILabel *)noDataLabel{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc]init];
        _noDataLabel.text = @"暂无流水记录哦~";
        _noDataLabel.font = [UIFont systemFontOfSize:18];
        _noDataLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
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
