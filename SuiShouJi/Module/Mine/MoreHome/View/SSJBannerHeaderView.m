//
//  SSJBannerHeaderView.m
//  SuiShouJi
//
//  Created by ricky on 16/7/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBannerHeaderView.h"
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
        self.images = [NSMutableArray arrayWithCapacity:0];
        for (SSJBannerItem *item in self.items) {
            [self.images addObject:item.bannerImageUrl];
        }
    }
    return self;
}

-(SCYWinCowryHomeBannerView *)banner{
    if (!_banner) {
        _banner = [[SCYWinCowryHomeBannerView alloc]initWithFrame:self.bounds];
        _banner.imageUrls = self.images;
        __weak typeof(self) weakSelf = self;
        _banner.tapAction = ^(SCYWinCowryHomeBannerView *view, NSUInteger tapIndex){
            SSJBannerItem *item = [weakSelf.items objectAtIndex:tapIndex];
            if (weakSelf.bannerClickedBlock) {
                weakSelf.bannerClickedBlock(item.bannerUrl);
            }
        };
    }
    return _banner;
}

-(UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(self.width - 10, 10, 30, 30)];
        [_closeButton setImage:[UIImage imageNamed:@"banner_cha"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

-(void)closeButtonClick:(id)sender{
    if (self.closeButtonClickBlock) {
        self.closeButtonClickBlock();
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
