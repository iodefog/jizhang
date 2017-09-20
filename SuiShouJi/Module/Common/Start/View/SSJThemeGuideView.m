    //
//  SSJThemeGuideView.m
//  SuiShouJi
//
//  Created by ricky on 2017/9/14.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJThemeGuideView.h"
#import "SSJThemeSelectButton.h"
#import "SSJThemeDownLoaderManger.h"

@interface SSJThemeGuideView()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UILabel *subTitleLab;

@property (nonatomic, strong) NSMutableArray <SSJThemeSelectButton *> *buttons;

@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong) NSArray *themeIds;

@property (nonatomic) NSInteger selectIndex;

@end


@implementation SSJThemeGuideView

@synthesize isNormalState = _isNormalState;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.images = @[@"theme0",@"theme7",@"theme5",@"theme8",@"theme3",@"theme10"];
        self.themeIds = @[@"0",@"7",@"5",@"8",@"3",@"10"];
        [self addSubview:self.titleLab];
        [self addSubview:self.subTitleLab];
        self.selectIndex = 0;
        self.isNormalState = YES;
        [self createButtons];
    }
    return self;
}

- (void)updateConstraints {
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(85);
        make.centerX.mas_equalTo(self);
    }];

    [self.subTitleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLab.mas_bottom).offset(50);
        make.centerX.mas_equalTo(self);
    }];

    for (SSJThemeSelectButton *button in self.buttons) {
        [button mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(97.5 , 97.5));
            if (button.tag == 1 || button.tag == 4) {
                make.centerX.mas_equalTo(self);
            } else if (button.tag == 0 || button.tag == 3) {
                make.right.mas_equalTo([self viewWithTag:1].mas_left).offset(-15);
            } else if (button.tag == 2 || button.tag == 5) {
                make.left.mas_equalTo([self viewWithTag:1].mas_right).offset(15);
            }
            if (button.tag / 3 == 0) {
                make.top.mas_equalTo(self.subTitleLab.mas_bottom).offset(50);
            } else {
                make.top.mas_equalTo([self viewWithTag:1].mas_bottom).offset(50);
            }
        }];
    }

    [super updateConstraints];
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = @"主题与记账的完美适配";
        _titleLab.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _titleLab.font = [UIFont ssj_compatibleBoldSystemFontOfSize:SSJ_FONT_SIZE_2];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.numberOfLines = 0;
    }
    return _titleLab;
}

- (UILabel *)subTitleLab {
    if (!_subTitleLab) {
        _subTitleLab = [[UILabel alloc] init];
        _subTitleLab.text = @"一个有范的主题,让记账之旅打满鸡血";
        _subTitleLab.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _subTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _subTitleLab.textAlignment = NSTextAlignmentCenter;
        _subTitleLab.numberOfLines = 0;
    }
    return _subTitleLab;
}

- (void)createButtons {
    if (!self.buttons) {
        self.buttons = [NSMutableArray arrayWithCapacity:0];
    }
    
    for (int i = 0; i < self.images.count; i ++) {
        SSJThemeSelectButton *button = [SSJThemeSelectButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        [button setImage:[UIImage imageNamed:self.images[i]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            button.isSelected = YES;
        } else {
            button.isSelected = NO;
        }
        [self addSubview:button];
        [self.buttons addObject:button];
    }
}

- (void)startAnimating {
    for (SSJThemeSelectButton *button in self.buttons) {
        button.hidden = NO;
        if (button.tag / 3 == 0) {
            button.transform = CGAffineTransformMakeTranslation(self.width , 0);
        } else {
            button.transform = CGAffineTransformMakeTranslation(-self.width , 0);
        }
    }
    
    self.titleLab.alpha = 0;
    self.subTitleLab.alpha = 0;
    
    for (SSJThemeSelectButton *button in self.buttons) {
        [UIView animateWithDuration:2.f animations:^(void) {
            button.transform = CGAffineTransformIdentity;
            button.transform = CGAffineTransformIdentity;
            self.titleLab.alpha = 1.f;
            self.subTitleLab.alpha = 1.f;

        } completion:^(BOOL finished) {
            self.isNormalState = NO;
        }];
    }
}

- (void)buttonClicked:(UIButton *)sender {
    if (self.themeItems.count) {
        [self.buttons objectAtIndex:self.selectIndex].isSelected = NO;
        [self.buttons objectAtIndex:sender.tag].isSelected = YES;
        self.selectIndex = sender.tag;
        SSJThemeItem *item = [self.themeItems objectAtIndex:sender.tag];
        if (![item.themeId isEqualToString:@"0"]) {
            [[SSJThemeDownLoaderManger sharedInstance] downloadThemeWithItem:item success:^(SSJThemeItem *item) {
                [SSJThemeSetting switchToThemeID:item.themeId];
            } failure:^(NSError *error) {
                
            }];
        } else {
            [SSJThemeSetting switchToThemeID:@"0"];
        }
    }
}

- (void)setIsNormalState:(BOOL)isNormalState {
    _isNormalState = isNormalState;
    if (!self.isNormalState && isNormalState) {
        self.titleLab.alpha = 0;
        self.subTitleLab.alpha = 0;
        for (SSJThemeSelectButton *button in self.buttons) {
            button.hidden = YES;
            if (button.tag / 3 == 0) {
                button.transform = CGAffineTransformMakeTranslation(self.width , 0);
            } else {
                button.transform = CGAffineTransformMakeTranslation(-self.width , 0);
            }
        }
    }
}

- (void)setThemeItems:(NSArray<SSJThemeItem *> *)themeItems {
    _themeItems = themeItems;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
