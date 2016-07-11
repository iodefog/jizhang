//
//  SSJBookKeepingHomeNodateFooter.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomeNodateFooter.h"
@interface SSJBookKeepingHomeNodateFooter()
@property (nonatomic,strong) UIImageView *bearImage;
@property (nonatomic,strong) UIImageView *arrowImage;
@property (nonatomic,strong) UILabel *firstLineLabel;
@property (nonatomic,strong) UILabel *secondLineLabel;
@end

@implementation SSJBookKeepingHomeNodateFooter

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.bearImage];
    }
    return self;
}

-(void)layoutSubviews{
    self.bearImage.size = CGSizeMake(320, 284);
    self.bearImage.top = 10;
    self.bearImage.centerX = self.width / 2;

}

-(UIImageView *)bearImage{
    if (!_bearImage) {
        _bearImage = [[UIImageView alloc]init];
        _bearImage.image = [UIImage ssj_themeImageWithName:@"home_none"];
    }
    return _bearImage;
}

//-(UIImageView *)arrowImage{
//    if (!_arrowImage) {
//        _arrowImage = [[UIImageView alloc]init];
//        _arrowImage.image = [UIImage imageNamed:@"home_jiantou"];
//    }
//    return _arrowImage;
//}
//
//-(UILabel *)firstLineLabel{
//    if (!_firstLineLabel) {
//        _firstLineLabel = [[UILabel alloc]init];
//        _firstLineLabel.font = [UIFont systemFontOfSize:18];
//        _firstLineLabel.textColor = [UIColor ssj_colorWithHex:@"47cfbe"];
//        _firstLineLabel.textAlignment = NSTextAlignmentCenter;
//        _firstLineLabel.text = @"现在就踏出第一步吧";
//        [_firstLineLabel sizeToFit];
//    }
//    return _firstLineLabel;
//}
//
//-(UILabel *)secondLineLabel{
//    if (!_secondLineLabel) {
//        _secondLineLabel = [[UILabel alloc]init];
//        _secondLineLabel.font = [UIFont systemFontOfSize:18];
//        _secondLineLabel.textColor = [UIColor ssj_colorWithHex:@"cccccc"];
//        _secondLineLabel.textAlignment = NSTextAlignmentCenter;
//        _secondLineLabel.text = @"小处不省钱袋空";
//        [_secondLineLabel sizeToFit];
//
//    }
//    return _secondLineLabel;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
