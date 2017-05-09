//
//  SSJBillingChargeHeaderView.m
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBillingChargeHeaderView.h"

@interface SSJBillingChargeHeaderView ()

@property (nonatomic, strong) UILabel *sumLabel;

@end

@implementation SSJBillingChargeHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.textLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [self.contentView addSubview:self.sumLabel];
        self.backgroundView = [[UIView alloc] init];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.left = 10;
    self.sumLabel.width = self.contentView.width - self.textLabel.right - 10;
    self.sumLabel.height = self.contentView.height;
    self.sumLabel.right = self.contentView.width - 10;
}

- (UILabel *)sumLabel {
    if (!_sumLabel) {
        _sumLabel = [[UILabel alloc] init];
        _sumLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _sumLabel.textAlignment = NSTextAlignmentRight;
    }
    return _sumLabel;
}

@end
