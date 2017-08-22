//
//  SSJRecycleListCell.m
//  SuiShouJi
//
//  Created by old lang on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRecycleListCell.h"

@interface _SSJRecycleListCellSeparatorView : UIView

@property (nonatomic, strong) NSArray<NSString *> *titles;

@property (nonatomic, strong) NSArray<UILabel *> *labels;

@end

@implementation _SSJRecycleListCellSeparatorView

- (void)dealloc {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
}

@end

@implementation SSJRecycleListCellItem

@end

@interface SSJRecycleListCell ()

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation SSJRecycleListCell

- (void)dealloc {
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJRecycleListCellItem class]]) {
        return;
    }
    
    SSJRecycleListCellItem *item = cellItem;
    [self updateExpanded:item.expanded animated:NO];
    
    @weakify(self);
    [[[RACObserve(item, expanded) skip:1] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *expandedValue) {
        @strongify(self);
        [self updateExpanded:[expandedValue boolValue] animated:YES];
    }];
}

- (void)updateExpanded:(BOOL)expanded animated:(BOOL)animated {
    
}

@end
