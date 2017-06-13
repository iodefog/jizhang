//
//  SSJCodeInputView.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCodeInputView.h"


@interface SSJCodeInputView()

@property(nonatomic) UIEdgeInsets clearButtonInsects;

@property(nonatomic) UIEdgeInsets editeInsects;

@end

@implementation SSJCodeInputView

- (instancetype)initWithFrame:(CGRect)frame
           clearButtonInsects:(UIEdgeInsets)clearInsects
                  editeInsect:(UIEdgeInsets)editeInsect
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clearButtonInsects = clearInsects;
        self.editeInsects = editeInsect;
    }
    return self;
}


- (CGRect)clearButtonRectForBounds:(CGRect)bounds{
    
    CGRect rect = [super clearButtonRectForBounds:bounds];
    
    
    return UIEdgeInsetsInsetRect(rect, self.clearButtonInsects);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect rect = [super textRectForBounds:bounds];
    
    
    return UIEdgeInsetsInsetRect(rect, self.editeInsects);

}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
