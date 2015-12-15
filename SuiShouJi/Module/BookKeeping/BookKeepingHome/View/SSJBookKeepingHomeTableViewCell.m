//
//  SSJBookKeepingHomeTableViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/15.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomeTableViewCell.h"
#import "SSJBookKeepingHomeView.h"
#import "SSJBookKeepingSummaryView.h"

@interface SSJBookKeepingHomeTableViewCell()
@property (nonatomic, strong) SSJBookKeepingSummaryView *summaryView;
@property (nonatomic, strong) NSMutableArray *bookKeepingViewArray;
@end

@implementation SSJBookKeepingHomeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.bookKeepingViewArray = [[NSMutableArray alloc]init];
        SSJBookKeepingHomeView *bookKeepingView = [[SSJBookKeepingHomeView alloc]initWithFrame:CGRectZero];
        [_bookKeepingViewArray addObject:bookKeepingView];
        [self.contentView addSubview:bookKeepingView];
        _summaryView = [SSJBookKeepingSummaryView BookKeepingSummaryView];
        [self.contentView addSubview:_summaryView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _summaryView.frame = CGRectMake(0, self.contentView.height - 50, self.contentView.width, 50);
    ((SSJBookKeepingHomeView*)[_bookKeepingViewArray objectAtIndex:0]).frame = CGRectMake(0, 0, self.contentView.width, 50);
}
@end
