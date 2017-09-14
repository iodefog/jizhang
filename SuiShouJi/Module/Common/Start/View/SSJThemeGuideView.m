//
//  SSJThemeGuideView.m
//  SuiShouJi
//
//  Created by ricky on 2017/9/14.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJThemeGuideView.h"

@interface SSJThemeGuideView()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UILabel *subTitleLab;

@property (nonatomic, strong) NSMutableArray *buttons;

@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong) NSArray *themeIds;

@end

@implementation SSJThemeGuideView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.images = @[@"",@"",@"",@"",@"",@""];
        self.themeIds = @[@"0",@"7",@"5",@"8",@"3",@"10"];
    }
    return self;
}


- (void)startAnimating {
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
