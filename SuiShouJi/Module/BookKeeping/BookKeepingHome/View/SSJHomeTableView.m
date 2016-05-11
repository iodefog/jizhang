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

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.lineView];
        self.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
        [self ssj_clearExtendSeparator];
        if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
            [self setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.lineView.top = 0;
    self.lineView.centerX = self.width / 2;
    self.lineView.height = self.lineHeight;
}


-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 0)];
        _lineView.backgroundColor = SSJ_DEFAULT_SEPARATOR_COLOR;
    }
    return _lineView;
}

-(void)setLineHeight:(float)lineHeight{
    _lineHeight = lineHeight;
    [self setNeedsLayout];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if (self.tableViewClickBlock) {
        self.tableViewClickBlock();
    }
}

@end
