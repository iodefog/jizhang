//
//  SSJMineHomeBannerHeader.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJMineHomeBannerHeader.h"

@interface SSJMineHomeBannerHeader()

@end

@implementation SSJMineHomeBannerHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bannerView];
    }
    return self;
}

- (void)dealloc {
    [self.bannerView stopAutoRoll];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bannerView.size = CGSizeMake(self.width, self.height - 20);
    self.bannerView.centerY = self.height / 2;
    self.bannerView.left = 0;
}

- (SCYWinCowryHomeBannerView *)bannerView {
    if (!_bannerView) {
        _bannerView = [[SCYWinCowryHomeBannerView alloc] init];
    }
    return _bannerView;
}

- (void)setItems:(NSArray<SSJBannerItem *> *)items {
    _items = items;
    NSMutableArray *imageArr = [NSMutableArray arrayWithCapacity:0];
    for (SSJBannerItem *item in items) {
        [imageArr addObject:item.bannerImageUrl];
    }
    self.bannerView.imageUrls = imageArr;
    [self.bannerView beginAutoRoll];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
