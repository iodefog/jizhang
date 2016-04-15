//
//  SSJHomeTableView.m
//  SuiShouJi
//
//  Created by ricky on 16/4/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJHomeTableView.h"

@implementation SSJHomeTableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundView = nil;
        self.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
        self.separatorColor = SSJ_DEFAULT_SEPARATOR_COLOR;
        [self ssj_clearExtendSeparator];
        if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
            [self setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    return self;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if (self.tableViewClickBlock) {
        self.tableViewClickBlock();
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
