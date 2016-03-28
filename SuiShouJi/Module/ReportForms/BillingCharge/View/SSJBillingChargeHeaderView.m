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
        self.textLabel.font = [UIFont systemFontOfSize:15];
        self.textLabel.textColor = [UIColor ssj_colorWithHex:@"#a7a7a7"];
        self.contentView.backgroundColor = [UIColor ssj_colorWithHex:@"#f6f6f6"];
        [self.contentView addSubview:self.sumLabel];
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
        _sumLabel.font = [UIFont systemFontOfSize:15];
        _sumLabel.textColor = [UIColor ssj_colorWithHex:@"#a7a7a7"];
        _sumLabel.textAlignment = NSTextAlignmentRight;
    }
    return _sumLabel;
}

@end
