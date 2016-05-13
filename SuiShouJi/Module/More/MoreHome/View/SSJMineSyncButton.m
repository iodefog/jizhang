//
//  SSJMineSyncButton.m
//  SuiShouJi
//
//  Created by ricky on 16/5/12.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMineSyncButton.h"
@interface SSJMineSyncButton()
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UIButton *syncButton;
@property(nonatomic, strong) UIImageView *cloudImage;
@property(nonatomic, strong) UIImageView *circleImage;
@property(nonatomic, strong) UILabel *titleLabel;
@end

@implementation SSJMineSyncButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.containerView];
        [self addSubview:self.cloudImage];
        [self addSubview:self.circleImage];
        [self addSubview:self.titleLabel];
        [self addSubview:self.syncButton];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
}

-(UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc]init];
        _containerView.backgroundColor = [UIColor clearColor];
    }
    return _containerView;
}

-(UIButton *)syncButton{
    if (!_syncButton) {
        _syncButton = [[UIButton alloc]init];
        [_syncButton addTarget:self action:@selector(syncButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _syncButton;
}

-(UIImageView *)circleImage{
    if (!_circleImage) {
        _circleImage = [[UIImageView alloc]init];
        _circleImage.image = [UIImage imageNamed:@"more_tongbucircle"];
    }
    return _circleImage;
}

-(UIImageView *)cloudImage{
    if (!_cloudImage) {
        _cloudImage = [[UIImageView alloc]init];
        _cloudImage.image = [UIImage imageNamed:@"more_tongbu"];
    }
    return _cloudImage;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"云同步";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

-(void)syncButtonClicked:(id)sender{
    
}

-(void)startAnimation{
    
}

-(void)stopAnimation{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
