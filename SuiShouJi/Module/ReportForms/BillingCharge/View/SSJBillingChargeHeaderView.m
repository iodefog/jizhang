//
//  SSJBillingChargeHeaderView.m
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBillingChargeHeaderView.h"

@implementation SSJBillingChargeHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.textLabel.font = [UIFont systemFontOfSize:15];
        self.textLabel.textColor = [UIColor ssj_colorWithHex:@"#a7a7a7"];
        self.contentView.backgroundColor = [UIColor ssj_colorWithHex:@"#f6f6f6"];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.left = 10;
}

@end
