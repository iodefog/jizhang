//
//  SSJCustomKeyBoardButton.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/16.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCustomKeyBoardButton.h"

@implementation SSJCustomKeyBoardButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF"];
        [self ssj_setBorderStyle:SSJBorderStyleRight | SSJBorderStyleTop];
        [self ssj_setBorderColor:[UIColor blackColor]];
        [self ssj_setBorderWidth:1];
        [self setTitleColor:[UIColor ssj_colorWithHex:@"#393939"] forState:UIControlStateNormal];
    }
    return self;
}

@end
