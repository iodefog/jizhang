//
//  SSJBannerHeaderView.m
//  SuiShouJi
//
//  Created by ricky on 16/7/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBannerHeaderView.h"
#import "SCYWinCowryHomeBannerView.h"
#import "SSJBannerItem.h"

@interface SSJBannerHeaderView()
@property(nonatomic, strong) SCYWinCowryHomeBannerView *banner;
@property(nonatomic, strong) UIButton *closeButton;
@property(nonatomic, strong) NSMutableArray *images;
@end
@implementation SSJBannerHeaderView

- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.banner];
        [self.contentView addSubview:self.closeButton];
        self.images = [NSMutableArray arrayWithCapacity:0];
        for (SSJBannerItem *item in self.items) {
            [self.images addObject:item.bannerImageUrl];
        }
    }
    return self;
}

-(SCYWinCowryHomeBannerView *)banner{
    if (!_banner) {
        _banner = [[SCYWinCowryHomeBannerView alloc]initWithFrame:self.contentView.bounds];
        _banner.imageUrls = self.images;
        _banner.tapAction = ^(SCYWinCowryHomeBannerView *view, NSUInteger tapIndex){
            
        };
    }
    return _banner;
}

-(UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(self.contentView.width - 10, 10, 30, 30)];
        [_closeButton setImage:[UIImage imageNamed:@"banner_cha"] forState:UIControlStateNormal];
    }
    return _closeButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
