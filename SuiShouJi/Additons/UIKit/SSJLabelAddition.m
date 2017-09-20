//
//  SSJLabelAddition.m
//  SuiShouJi
//
//  Created by old lang on 2017/9/20.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJLabelAddition.h"

@implementation UILabel (SSJCategory)

- (CGSize)ssj_textSize {
    return [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
}

@end
