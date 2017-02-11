//
//  SSJFundingTransferListPeriodCell.m
//  SuiShouJi
//
//  Created by old lang on 17/2/10.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFundingTransferListPeriodCell.h"
#import "Masonry.h"

@interface SSJFundingTransferListPeriodCell ()

@end

@implementation SSJFundingTransferListPeriodCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIView *purpleView = [[UIView alloc] init];
    purpleView.backgroundColor = [UIColor purpleColor];
    [self addSubview:purpleView];
    [purpleView mas_makeConstraints:^(MASConstraintMaker *make) {
        // 在这个 block 里面，利用 make 对象创建约束
        make.size.mas_equalTo(@"");
        make.center.mas_equalTo(self);
    }];
}



@end
