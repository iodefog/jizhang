//
//  SSJThemeSelectButton.m
//  SuiShouJi
//
//  Created by ricky on 2017/9/14.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJThemeSelectButton.h"

@interface SSJThemeSelectButton()

@property (nonatomic, strong) UIImageView *selectImage;

@end


@implementation SSJThemeSelectButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.selectImage];
    }
    return self;
}

- (void)updateConstraints {
    [self.selectImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_right).offset(-10);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
    }];
    
    [super updateConstraints];
}

- (UIImageView *)selectImage {
    if (_selectImage) {
        _selectImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"theme_select_checkmark"]];
    }
    return _selectImage;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    self.selectImage.hidden = _isSelected;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
