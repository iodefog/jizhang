//
//  SSJMagicExportCalendarWeekView.m
//  SuiShouJi
//
//  Created by old lang on 16/4/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportCalendarWeekView.h"

@interface SSJMagicExportCalendarWeekView ()

@property (nonatomic, strong) NSMutableArray *labelArr;

@end

@implementation SSJMagicExportCalendarWeekView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        
        NSArray *weekArr = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
        _labelArr = [[NSMutableArray alloc] initWithCapacity:weekArr.count];
        for (NSString *week in weekArr) {
            UILabel *lab = [[UILabel alloc] init];
            lab.backgroundColor = [UIColor clearColor];
            lab.font = [UIFont systemFontOfSize:13];
            lab.text = week;
            lab.textAlignment = NSTextAlignmentCenter;
            lab.textColor = ([week isEqualToString:@"日"] || [week isEqualToString:@"六"]) ? [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] : [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
            [_labelArr addObject:lab];
            [self addSubview:lab];
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

- (void)updateAppearance {
    self.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    for (UILabel *lab in _labelArr) {
        lab.textColor = ([lab.text isEqualToString:@"日"] || [lab.text isEqualToString:@"六"]) ? [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] : [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
}

@end
