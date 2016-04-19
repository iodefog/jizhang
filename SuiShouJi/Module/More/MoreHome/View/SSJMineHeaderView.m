//
//  SSJMineHeaderView.m
//  SuiShouJi
//
//  Created by ricky on 16/4/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMineHeaderView.h"
@interface SSJMineHeaderView()
@end

@implementation SSJMineHeaderView

-(void)awakeFromNib{
    self.layer.cornerRadius = self.height / 2;
    self.layer.borderColor =  [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.headerImage];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.headerImage.size = CGSizeMake(self.width - 6, self.height - 6);
    self.headerImage.center = CGPointMake(self.width / 2, self.height / 2);
}

-(UIImageView *)headerImage{
    if (!_headerImage) {
        _headerImage = [[UIImageView alloc]init];
        _headerImage.layer.cornerRadius = (self.width - 6) / 2;
        _headerImage.layer.masksToBounds = YES;
    }
    return _headerImage;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
