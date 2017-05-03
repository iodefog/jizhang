//
//  SSJCalenderDetaiImagelFooterView.m
//  SuiShouJi
//
//  Created by ricky on 16/4/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCalenderDetaiImagelFooterView.h"

@interface SSJCalenderDetaiImagelFooterView()
@property(nonatomic, strong) UILabel *cellLabel;
@property(nonatomic, strong) UIImageView *photoImage;
@property(nonatomic, strong) UIButton *modifyButton;
@end

@implementation SSJCalenderDetaiImagelFooterView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.cellLabel];
        [self addSubview:self.photoImage];
        [self addSubview:self.modifyButton];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.cellLabel.leftTop = CGPointMake(10, 15);
    self.photoImage.size = CGSizeMake(200, 150);
    self.photoImage.top = self.cellLabel.bottom + 5;
    self.photoImage.centerX = self.width / 2;
    self.modifyButton.size = CGSizeMake(self.width - 22, 40);
    self.modifyButton.top = self.photoImage.bottom + 25;
    self.modifyButton.centerX = self.width / 2;
}

-(UILabel *)cellLabel{
    if (_cellLabel == nil) {
        _cellLabel = [[UILabel alloc]init];
        _cellLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        _cellLabel.textAlignment = NSTextAlignmentLeft;
        _cellLabel.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
        _cellLabel.text = @"照片";
        [_cellLabel sizeToFit];
    }
    return _cellLabel;
}

-(UIImageView *)photoImage{
    if (!_photoImage) {
        _photoImage = [[UIImageView alloc]init];
        _photoImage.layer.cornerRadius = 4.f;
        _photoImage.layer.masksToBounds = YES;
        _photoImage.userInteractionEnabled = YES;
        UITapGestureRecognizer *backsingleTap =
        [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClicked:)];
        [_photoImage addGestureRecognizer:backsingleTap];
    }
    return _photoImage;
}

-(UIButton *)modifyButton{
    if (!_modifyButton) {
        _modifyButton = [[UIButton alloc]init];
        [_modifyButton setTitle:@"修改此记录" forState:UIControlStateNormal];
        [_modifyButton setTitleColor:[UIColor ssj_colorWithHex:@"eb4a64"] forState:UIControlStateNormal];
        _modifyButton.layer.borderWidth = 1.f;
        _modifyButton.layer.cornerRadius = 2.f;
        _modifyButton.layer.borderColor = [UIColor ssj_colorWithHex:@"eb4a64"].CGColor;
        [_modifyButton addTarget:self action:@selector(modifyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _modifyButton;
}

-(void)modifyButtonClicked:(id)sender{
    if (self.ModifyButtonClickedBlock) {
        self.ModifyButtonClickedBlock();
    }
}

-(void)setImageName:(NSString *)imageName{
    _imageName = imageName;
    if ([[NSFileManager defaultManager] fileExistsAtPath:SSJImagePath(_imageName)]) {
        [self.photoImage sd_setImageWithURL:[NSURL fileURLWithPath:SSJImagePath(_imageName)]];
    }else{
        [self.photoImage sd_setImageWithURL:[NSURL URLWithString:SSJGetChargeImageUrl(_imageName)]];
    }
}

-(void)imageClicked:(id)sender{
    if (self.ImageClickedBlock) {
        self.ImageClickedBlock();
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
