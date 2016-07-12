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
        
    }
    return self;
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
        _noDataLabel.text = @"暂无流水记录哦~";
        _noDataLabel.font = [UIFont systemFontOfSize:18];
        _noDataLabel.textColor = [UIColor ssj_colorWithHex:@""];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
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
