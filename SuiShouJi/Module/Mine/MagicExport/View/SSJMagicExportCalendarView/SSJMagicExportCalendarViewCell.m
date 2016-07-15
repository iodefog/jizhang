//
//  SSJMagicExportCalendarViewCell.m
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportCalendarViewCell.h"
#import "SSJMagicExportCalendarDateView.h"
#import "SSJMagicExportCalendarDateViewItem.h"

@interface SSJMagicExportCalendarViewCell ()

@property (nonatomic, strong) NSMutableArray *dateViewArr;

@end

@implementation SSJMagicExportCalendarViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _dateViewArr = [NSMutableArray arrayWithCapacity:7];
        for (int i = 0; i < 7; i ++) {
            SSJMagicExportCalendarDateView *dateView = [[SSJMagicExportCalendarDateView alloc] init];
            __weak typeof(self) weakSelf = self;
            
            dateView.shouldSelectBlock = ^BOOL(SSJMagicExportCalendarDateView *dateView) {
                BOOL shouldSelect = YES;
                if (weakSelf.shouldSelectBlock) {
                    shouldSelect = weakSelf.shouldSelectBlock(weakSelf, dateView);
                }
                return shouldSelect;
            };
            
            dateView.didSelectBlock = ^(SSJMagicExportCalendarDateView *dateView) {
                if (weakSelf.didSelectBlock) {
                    weakSelf.didSelectBlock(weakSelf, dateView);
                }
            };
            
            [_dateViewArr addObject:dateView];
            [self.contentView addSubview:dateView];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat dateViewWidth = self.contentView.width / _dateViewArr.count;
    for (int i = 0; i < _dateViewArr.count; i ++) {
        SSJMagicExportCalendarDateView *dateView = _dateViewArr[i];
        dateView.frame = CGRectMake(dateViewWidth * i, 0, dateViewWidth, self.contentView.height);
    }
}

- (void)setDateItems:(NSArray<SSJMagicExportCalendarDateViewItem *> *)dateItems {
    _dateItems = dateItems;
    for (int i = 0; i < _dateItems.count; i ++) {
        SSJMagicExportCalendarDateView *dateView = [_dateViewArr ssj_safeObjectAtIndex:i];
        dateView.item = _dateItems[i];
    }
}

@end
