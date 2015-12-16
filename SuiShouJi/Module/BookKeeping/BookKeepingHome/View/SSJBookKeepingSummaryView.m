//
//  SSJBookKeepingSummaryView.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/15.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingSummaryView.h"
@interface SSJBookKeepingSummaryView()
@property (weak, nonatomic) IBOutlet UILabel *expenditureSummaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@end

@implementation SSJBookKeepingSummaryView

+ (id)BookKeepingSummaryView{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SSJBookKeepingSummaryView" owner:nil options:nil];
    return array[0];
}

-(void)awakeFromNib{
    
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(ctx, self.centerX, 0);
    CGContextAddLineToPoint(ctx, self.centerX, self.height);
    CGContextSetRGBStrokeColor(ctx, 204.0/225, 204.0/255, 204.0/255, 1.0);
    CGContextSetLineWidth(ctx, 1 / [UIScreen mainScreen].scale);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextStrokePath(ctx);
}

@end
