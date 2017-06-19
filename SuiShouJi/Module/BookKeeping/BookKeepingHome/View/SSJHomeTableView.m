//
//  SSJHomeTableView.m
//  SuiShouJi
//
//  Created by ricky on 16/4/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJHomeTableView.h"

@interface SSJHomeTableView()
@property(nonatomic, strong) UIView *lineView;
@end

@implementation SSJHomeTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self addSubview:self.lineView];
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
//        [self ssj_clearExtendSeparator];
        if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
            [self setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
//    self.lineView.height = 0;
    self.lineView.centerX = self.width / 2;
    self.lineView.height = self.lineHeight;
//  self.lineView.top = 0;
    self.lineView.top = - self.lineHeight;
}


-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 3, 0)];
        _lineView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor];
    }
    return _lineView;
}

-(void)setLineHeight:(float)lineHeight{
    _lineHeight = lineHeight;
//    self.lineView.height = self.lineHeight + 1;
    [self setNeedsLayout];
}

-(void)setHasData:(BOOL)hasData{
    _hasData = hasData;
    if (!_hasData) {
        self.lineView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.recordHomeBorderColor];
        self.lineView.width = 1.5f;
    }else{
        self.lineView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor];
        self.lineView.width = 1.f;
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if (self.tableViewClickBlock) {
        self.tableViewClickBlock();
    }
}

- (void)updateAfterThemeChange{
    self.lineView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor];
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
}

@end
