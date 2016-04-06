//
//  SSJMagicExportCalendarWeekView.m
//  SuiShouJi
//
//  Created by old lang on 16/4/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportCalendarWeekView.h"

@interface SSJMagicExportCalendarWeekView ()

@property (nonatomic, strong) NSArray *weekArr;

@property (nonatomic, strong) NSMutableArray *labelArr;

@end

@implementation SSJMagicExportCalendarWeekView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        NSArray *weekArr = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
        _labelArr = [[NSMutableArray alloc] initWithCapacity:weekArr.count];
        for (NSString *week in weekArr) {
            UILabel *lab = [[UILabel alloc] init];
            lab.backgroundColor = [UIColor whiteColor];
            lab.font = [UIFont systemFontOfSize:13];
            lab.textColor = ([week isEqualToString:@"日"] || [week isEqualToString:@"六"]) ? [UIColor ssj_colorWithHex:@"00ccb3"] : [UIColor ssj_colorWithHex:@"393939"];
            lab.textAlignment = NSTextAlignmentCenter;
            [_labelArr addObject:lab];
        }
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat width = self.width / _labelArr.count;
    for (int i = 0; i < _labelArr.count; i ++) {
        UILabel *lab = _labelArr[i];
        lab.frame = CGRectMake(width * i, 0, width, self.height);
    }
}

@end
