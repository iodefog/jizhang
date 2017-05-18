//
//  SSJBookKeepingHomeTableViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/15.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomeTableViewCell.h"
#import "SSJDataSynchronizer.h"
#import "SSJCalenderHelper.h"

@interface SSJBookKeepingHomeTableViewCell()

@property (nonatomic, strong) UIView *verticalLine;

@property (nonatomic, strong) UIView *labelContainer;

@property (nonatomic, strong) UILabel *topLabel;

@property (nonatomic, strong) UILabel *bottomLabel;

@property (nonatomic, strong) UIImageView *chargeImage;

@property (nonatomic, strong) UIButton *categoryImageButton;

@end

@implementation SSJBookKeepingHomeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.isAnimating = NO;
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addSubview:self.verticalLine];
        [self addSubview:self.categoryImageButton];
        [self addSubview:self.labelContainer];
        [self addSubview:self.chargeImage];
        [self updateAppearance];
    }
    return self;
}

- (void)updateConstraints {
    [self.verticalLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(self.contentView);
        make.center.mas_equalTo(self.contentView);
    }];
    [self.categoryImageButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(46, 46));
        make.center.mas_equalTo(self.contentView);
    }];
    
    if (self.item.incomeOrExpence) {
        [self.labelContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.categoryImageButton.mas_right).offset(10);
            make.right.mas_equalTo(self.contentView).offset(-16);
            make.centerY.mas_equalTo(self.contentView);
        }];
        [self.chargeImage mas_updateConstraints:^(MASConstraintMaker *make) {
            
        }];
        
        
    } else {
        
    }
    
    if (self.bottomLabel.text.length) {
        [self.topLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.labelContainer);
            make.left.and.right.mas_equalTo(self.labelContainer);
        }];
        [self.bottomLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.topLabel.mas_bottom).offset(6);
            make.left.and.right.and.bottom.mas_equalTo(self.labelContainer);
        }];
    } else {
        [self.topLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.labelContainer);
            make.left.and.right.and.bottom.mas_equalTo(self.labelContainer);
        }];
    }
    
    [super updateConstraints];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

-(void)setItem:(SSJBillingChargeCellItem *)item {
    _item = item;
    
    self.topLabel.text = [NSString stringWithFormat:@"%@%.2f",_item.typeName,[_item.money doubleValue]];
    self.bottomLabel.text = _item.chargeMemo;
    
    UIImage *image = [[UIImage imageWithCGImage:[UIImage imageNamed:_item.imageName].CGImage scale:1.5*SSJ_SCREEN_SCALE orientation:UIImageOrientationUp] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_categoryImageButton setImage:image forState:UIControlStateNormal];
    _categoryImageButton.tintColor = [UIColor ssj_colorWithHex:_item.colorValue];
    _categoryImageButton.layer.borderColor = [UIColor ssj_colorWithHex:_item.colorValue].CGColor;
    
    if (self.item.chargeImage.length) {
        self.chargeImage.userInteractionEnabled = YES;
        if ([[NSFileManager defaultManager] fileExistsAtPath:SSJImagePath(self.item.chargeImage)]) {
            [self.chargeImage sd_setImageWithURL:[NSURL fileURLWithPath:SSJImagePath(_item.chargeImage)]];
        } else {
            [self.chargeImage sd_setImageWithURL:[NSURL fileURLWithPath:SSJGetChargeImageUrl(_item.chargeThumbImage)]];
        }
    } else {
        self.chargeImage.image = nil;
        self.chargeImage.userInteractionEnabled = YES;
    }
    
    [self setNeedsUpdateConstraints];
}

- (void)buttonClicked {
    
}

- (void)updateAppearance {
    self.topLabel.textColor = SSJ_MAIN_COLOR;
    self.bottomLabel.textColor = SSJ_SECONDARY_COLOR;
    self.verticalLine.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor];
    [self.categoryImageButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.recordHomeCategoryBackgroundColor] forState:UIControlStateNormal];
}

- (void)imageClick:(UITapGestureRecognizer *)sender {
    if (self.imageClickBlock) {
        self.imageClickBlock(self.item);
    }
}

- (void)setIsLastRowOrNot:(BOOL)isLastRowOrNot {
    _isLastRowOrNot = isLastRowOrNot;
    self.verticalLine.hidden = !_isLastRowOrNot;
}

- (void)shake {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    anim.keyPath = @"transform.translation.y";
    
    anim.values = @[@(-1),  @(1), @(-1)];
    
    anim.duration = 0.25;
    // 动画的重复执行次数
    anim.repeatCount = 2;
    
    // 保持动画执行完毕后的状态
    anim.removedOnCompletion = NO;
    
    anim.fillMode = kCAFillModeForwards;
    
    [self.categoryImageButton.layer addAnimation:anim forKey:@"shake"];
}

- (void)animatedShowCellWithDistance:(float)distance delay:(float)delay completion:(void (^ __nullable)())completion {
    if (!self.isAnimating) {
        self.topLabel.alpha = 0;
        self.bottomLabel.alpha = 0;
        self.categoryImageButton.transform = CGAffineTransformMakeTranslation(0, distance);
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.7 delay:delay options:UIViewAnimationOptionTransitionNone animations:^{
            weakSelf.categoryImageButton.transform = CGAffineTransformIdentity;
            weakSelf.isAnimating = YES;
        } completion:^(BOOL finished) {
            [weakSelf shake];
            [UIView animateWithDuration:0.4 animations:^{
                weakSelf.isAnimating = YES;
                weakSelf.topLabel.alpha = 1;
                weakSelf.bottomLabel.alpha = 1;
            } completion:^(BOOL finished) {
                if (completion) {
                    completion();
                }
            }];
        }];
    }
}

- (void)performAddOrEditAnimation {
    if (self.item.operatorType == 0) {
        self.categoryImageButton.transform = CGAffineTransformMakeTranslation(0,  - self.height / 2);
        self.topLabel.alpha = 0;
        self.bottomLabel.alpha = 0;
        
        self.topLabel.transform = CGAffineTransformMakeScale(0, 0);
        self.bottomLabel.transform = CGAffineTransformMakeScale(0, 0);
        self.chargeImage.layer.transform = CATransform3DMakeRotation(degreesToRadians(90) , -1, -1, 0);
        
        [UIView animateWithDuration:0.7 animations:^{
            self.topLabel.alpha = 1;
            self.bottomLabel.alpha = 1;
            self.categoryImageButton.transform = CGAffineTransformIdentity;
            self.chargeImage.layer.transform = CATransform3DIdentity;
        } completion:^(BOOL finished) {
            [self shake];
        }];
    } else {
        [self shake];
    }
}

#pragma mark - Lazyloading
- (UIView *)verticalLine {
    if (!_verticalLine) {
        _verticalLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1 , self.height / 2)];
        _verticalLine.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor];
    }
    return _verticalLine;
}

- (UIView *)labelContainer {
    if (!_labelContainer) {
        _labelContainer = [[UIView alloc] init];
        _labelContainer.backgroundColor = [UIColor clearColor];
        [_labelContainer addSubview:self.topLabel];
        [_labelContainer addSubview:self.bottomLabel];
    }
    return _labelContainer;
}

- (UILabel *)topLabel {
    if (!_topLabel) {
        _topLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _topLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _topLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [_topLabel sizeToFit];
    }
    return _topLabel;
}

- (UILabel *)bottomLabel {
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _bottomLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _bottomLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [_bottomLabel sizeToFit];
    }
    return _bottomLabel;
}

- (UIButton *)categoryImageButton {
    if (!_categoryImageButton) {
        _categoryImageButton = [[UIButton alloc]init];
        _categoryImageButton.layer.borderWidth = 1;
        _categoryImageButton.contentMode = UIViewContentModeCenter;
        _categoryImageButton.layer.masksToBounds = YES;
        [_categoryImageButton addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _categoryImageButton;
}

- (UIImageView *)chargeImage {
    if (!_chargeImage) {
        _chargeImage = [[UIImageView alloc] init];
        UITapGestureRecognizer *singleTap =
        [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick:)];
        singleTap.numberOfTapsRequired = 1;
        [_chargeImage addGestureRecognizer:singleTap];
    }
    return _chargeImage;
}

@end
