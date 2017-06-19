//
//  SSJBookKeepingHomeNoDataHeader.m
//  SuiShouJi
//
//  Created by ricky on 16/7/15.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomeNoDataHeader.h"

@interface SSJBookKeepingHomeNoDataHeader()
@property(nonatomic, strong) UIImageView *nodataImage;
@end

@implementation SSJBookKeepingHomeNoDataHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.nodataImage];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.nodataImage.top = 46;
    self.nodataImage.centerX = self.width / 2;
}

-(UIImageView *)nodataImage{
    if (!_nodataImage) {
        _nodataImage = [[UIImageView alloc]init];
        _nodataImage.image = [UIImage ssj_themeImageWithName:@"home_none"];
        [_nodataImage sizeToFit];
    }
    return _nodataImage;
}

-(void)updateAfterThemeChanged{
    self.nodataImage.image = [UIImage ssj_themeImageWithName:@"home_none"];
    [self.nodataImage sizeToFit];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
