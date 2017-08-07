//
//  SSJBannerHeaderView.m
//  SuiShouJi
//
//  Created by ricky on 16/7/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBannerHeaderView.h"
#import "SSJAdItem.h"
#import "SSJBannerItem.h"

@interface SSJBannerHeaderView()
@property(nonatomic, strong) UIButton *closeButton;
@property(nonatomic, strong) NSMutableArray *images;
@end
@implementation SSJBannerHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.banner];
        [self addSubview:self.closeButton];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.banner.frame = self.bounds;
    self.closeButton.rightTop = CGPointMake(self.width - 10, 10);
}

-(SCYWinCowryHomeBannerView *)banner{
    if (!_banner) {
        _banner = [[SCYWinCowryHomeBannerView alloc]initWithFrame:self.bounds];
        _banner.imageUrls = self.images;
        __weak typeof(self) weakSelf = self;
        _banner.tapAction = ^(SCYWinCowryHomeBannerView *view, NSUInteger tapIndex){
            SSJBannerItem *item = [weakSelf.items ssj_safeObjectAtIndex:tapIndex];
            [SSJAnaliyticsManager event:@"mine_banner" extra:item.bannerUrl];
            if (weakSelf.bannerClickedBlock) {
                weakSelf.bannerClickedBlock(item.bannerUrl,item.bannerName);
            }
        };
    }
    return _banner;
}

-(UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 19, 19)];
        [_closeButton setImage:[UIImage imageNamed:@"banner_cha"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

-(void)closeButtonClick:(id)sender{
    [SSJAnaliyticsManager event:@"mine_banner_close"];
    if (self.closeButtonClickBlock) {
        self.closeButtonClickBlock();
    }
}

-(void)setItems:(NSArray *)items{
    _items = items;
    self.images = [NSMutableArray arrayWithCapacity:0];
    for (SSJBannerItem *item in _items) {
        [self.images addObject:item.bannerImageUrl];
    }
    self.banner.imageUrls = self.images;
    [self setNeedsLayout];
    [self.banner beginAutoRoll];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
