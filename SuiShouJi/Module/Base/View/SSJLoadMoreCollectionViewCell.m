//
//  SSJLoadMoreCollectionViewCell.m
//  SuiShouJi
//
//  Created by cdd on 15/10/27.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJLoadMoreCollectionViewCell.h"

@interface SSJLoadMoreCollectionViewCell ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *label;

@end

@implementation SSJLoadMoreCollectionViewCell

- (void)dealloc{
    [self.indicatorView stopAnimating];
}

- (instancetype)init{
    self =[super init];
    if (self) {
    }
    return self;
}

- (UIActivityIndicatorView *)indicatorView{
    if (_indicatorView==nil) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_indicatorView startAnimating];
        [self.contentView addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (UILabel *)label{
    if (_label==nil) {
        _label=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.width-20, 30)];
        _label.font=SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_4);
        _label.textAlignment=NSTextAlignmentCenter;
        _label.text=@"点击加载更多";
        _label.textColor=[UIColor ssj_colorWithHex:@"#e0e0e0"];
        [self.contentView addSubview:_label];
    }
    return _label;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.backgroundColor=[UIColor whiteColor];
    self.layer.cornerRadius=3;
    self.layer.masksToBounds=YES;
    if (SSJSystemVersion()<8.0) {
        self.label.centerY=self.height*0.5;
    }else{
        self.indicatorView.center=CGPointMake(self.width*0.5, self.height*0.5);
    }
}

@end
