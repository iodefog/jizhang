//
//  SSJColorSelectCollectionViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJColorSelectCollectionViewCell.h"


@interface SSJColorSelectCollectionViewCell()
@property (nonatomic,strong) UIView *smallCircleView;
@end

@implementation SSJColorSelectCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = self.height / 2;
        [self addSubview:self.smallCircleView];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.smallCircleView.center = CGPointMake(self.width / 2, self.height / 2);
}

-(UIView *)smallCircleView{
    if (!_smallCircleView) {
        _smallCircleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width / 2, self.height / 2)];
        _smallCircleView.layer.cornerRadius = _smallCircleView.width / 2;
    }
    return _smallCircleView;
}

-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    if (_isSelected == YES) {
        [UIView animateWithDuration:0.2 animations:^{
            self.smallCircleView.transform = CGAffineTransformMakeScale(2, 2);
        }completion:nil];
    }else{
        self.smallCircleView.transform = CGAffineTransformMakeScale(1, 1);
    }

}

-(void)setItemColor:(NSString *)itemColor{
    _itemColor = itemColor;
    self.smallCircleView.backgroundColor = [UIColor ssj_colorWithHex:_itemColor];
    self.layer.borderColor = [UIColor ssj_colorWithHex:_itemColor].CGColor;
    self.layer.borderWidth = 1.0f;
}

@end
