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
#import <objc/runtime.h>

static const void *kExpandedKey = &kExpandedKey;

@implementation SSJBillingChargeCellItem (SSJBookKeepingHomeTableViewCell)

- (void)setExpanded:(BOOL)expanded {
    objc_setAssociatedObject(self, kExpandedKey, @(expanded), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)expanded {
    return [objc_getAssociatedObject(self, kExpandedKey) boolValue];
}

@end

static const CGFloat kCategoryImageButtonRadius = 16;
static const CGFloat kChargeImgWidth = 30;

@interface SSJBookKeepingHomeTableViewCell()

@property (nonatomic, strong) UIView *verticalLine;

@property (nonatomic, strong) UIView *labelContainer;

@property (nonatomic, strong) UILabel *topLabel;

@property (nonatomic, strong) UILabel *bottomLabel;

/**
 流水图片
 */
@property (nonatomic, strong) UIImageView *chargeImage;

/**
 收支类别按钮
 */
@property (nonatomic, strong) UIButton *categoryImageButton;

@property (nonatomic, strong) UIButton *editeButton;

@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation SSJBookKeepingHomeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.isAnimating = NO;
        
        [self.contentView addSubview:self.verticalLine];
        [self.contentView addSubview:self.categoryImageButton];
        [self.contentView addSubview:self.labelContainer];
        [self.contentView addSubview:self.chargeImage];
        [self.contentView addSubview:self.deleteButton];
        [self.contentView addSubview:self.editeButton];
        [self updateAppearance];
        [self updateSubviewsAlpha];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    [self.verticalLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(self.contentView).multipliedBy(self.isLastRow ? 0.5 : 1);
        make.top.mas_equalTo(self.contentView);
        make.centerX.mas_equalTo(self.contentView);
    }];
    [self.categoryImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kCategoryImageButtonRadius * 2, kCategoryImageButtonRadius * 2));
        make.center.mas_equalTo(self.contentView);
    }];
    
    if (self.item.incomeOrExpence) {
        [self.labelContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(10);
            make.bottom.mas_equalTo(self.contentView).offset(-10);
            make.left.mas_equalTo(self.categoryImageButton.mas_right).offset(16);
            make.right.mas_equalTo(self.contentView).offset(-16);
            make.height.mas_greaterThanOrEqualTo(46).priorityHigh();
        }];
        [self.chargeImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.categoryImageButton.mas_left).offset(-16);
            make.centerY.mas_equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(kChargeImgWidth, kChargeImgWidth));
        }];
    } else {
        [self.labelContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(10);
            make.bottom.mas_equalTo(self.contentView).offset(-10);
            make.left.mas_equalTo(self.contentView).offset(16);
            make.right.mas_equalTo(self.categoryImageButton.mas_left).offset(-16);
            make.height.mas_greaterThanOrEqualTo(46).priorityHigh();
        }];
        [self.chargeImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.categoryImageButton.mas_right).offset(16);
            make.centerY.mas_equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(kChargeImgWidth, kChargeImgWidth));
        }];
    }
  
    if (self.bottomLabel.text.length || self.bottomLabel.attributedText.length) {
        [self.topLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.and.right.mas_equalTo(self.labelContainer);
        }];
        [self.bottomLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.topLabel.mas_bottom).offset(2);
            make.left.and.right.and.bottom.mas_equalTo(self.labelContainer);
        }];
    } else {
        NSArray *installedConstraints = [MASViewConstraint installedConstraintsForView:self.bottomLabel];
        for (MASConstraint *constraint in installedConstraints) {
            [constraint uninstall];
        }
        
        [self.topLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.labelContainer);
        }];
    }
    
    [self.deleteButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.editAndDeleteBtnShowed) {
            make.left.mas_equalTo(20);
        } else {
            make.centerX.mas_equalTo(self.contentView);
        }
        make.size.mas_equalTo(CGSizeMake(kCategoryImageButtonRadius * 2, kCategoryImageButtonRadius * 2));
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [self.editeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.editAndDeleteBtnShowed) {
            make.right.mas_equalTo(-20);
        } else {
            make.centerX.mas_equalTo(self.contentView);
        }
        make.size.mas_equalTo(CGSizeMake(kCategoryImageButtonRadius * 2, kCategoryImageButtonRadius * 2));
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [super updateConstraints];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

-(void)setItem:(SSJBillingChargeCellItem *)item {
    _item = item;
    
    self.topLabel.text = [NSString stringWithFormat:@"%@%.2f",_item.typeName,[_item.money doubleValue]];
    if (_item.idType == SSJChargeIdTypeShareBooks) {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
        if ([_item.userId isEqualToString:SSJUSERID()]) {
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"我" attributes:@{NSForegroundColorAttributeName:SSJ_MAIN_COLOR}]];
        } else if (_item.memberNickname.length) {
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:_item.memberNickname attributes:@{NSForegroundColorAttributeName:SSJ_MAIN_COLOR}]];
        }
        
        if (_item.chargeMemo.length) {
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"｜%@", _item.chargeMemo] attributes:@{NSForegroundColorAttributeName:SSJ_SECONDARY_COLOR}]];
        }
        self.bottomLabel.attributedText = text;
    } else {
        self.bottomLabel.attributedText = nil;
        self.bottomLabel.text = _item.chargeMemo;
    }
    
    self.topLabel.textAlignment = self.bottomLabel.textAlignment = self.item.incomeOrExpence ? NSTextAlignmentLeft : NSTextAlignmentRight;
    
    UIImage *image = [[UIImage imageWithCGImage:[UIImage imageNamed:_item.imageName].CGImage scale:1.5*SSJ_SCREEN_SCALE orientation:UIImageOrientationUp] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_categoryImageButton setImage:image forState:UIControlStateNormal];
    _categoryImageButton.tintColor = [UIColor ssj_colorWithHex:_item.colorValue];
    _categoryImageButton.layer.borderColor = [UIColor ssj_colorWithHex:_item.colorValue].CGColor;
    
    if (self.item.chargeImage.length) {
        [UIImage ssj_loadUrl:SSJImageUrl(self.item.chargeThumbImage, SSJWebImgPathCharge) compeltion:^(NSError *error, UIImage *image) {
            if (!image) {
                return;
            }  
            if (image.size.width > image.size.height) {
                CGFloat x = (image.size.width - image.size.height) * 0.5;
                self.chargeImage.image = [image ssj_imageWithClipInsets:UIEdgeInsetsMake(0, x, 0, x) toSize:CGSizeMake(kChargeImgWidth, kChargeImgWidth)];
            } else {
                CGFloat x = (image.size.height - image.size.width) * 0.5;
                self.chargeImage.image = [image ssj_imageWithClipInsets:UIEdgeInsetsMake(x, 0, x, 0) toSize:CGSizeMake(kChargeImgWidth, kChargeImgWidth)];
            }
        }];
        self.chargeImage.userInteractionEnabled = YES;
    } else {
        self.chargeImage.image = nil;
        self.chargeImage.userInteractionEnabled = NO;
    }
    
    [self setNeedsUpdateConstraints];
    
    @weakify(self);
    [[[RACObserve(_item, expanded) skip:1] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *expandedValue) {
        @strongify(self);
        [self showEditAndDeleteBtn:[expandedValue boolValue] animated:YES];
    }];
    [self showEditAndDeleteBtn:_item.expanded animated:NO];
}

- (void)setIsLastRow:(BOOL)isLastRow {
    if (_isLastRow != isLastRow) {
        _isLastRow = isLastRow;
        [self setNeedsUpdateConstraints];
    }
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
        [self shake];

        self.categoryImageButton.transform = CGAffineTransformMakeTranslation(0,  - self.height / 2);
        self.topLabel.alpha = 0;
        self.bottomLabel.alpha = 0;
        
//        self.topLabel.transform = CGAffineTransformMakeScale(0, 0);
//        self.bottomLabel.transform = CGAffineTransformMakeScale(0, 0);
        self.chargeImage.layer.transform = CATransform3DMakeRotation(degreesToRadians(90) , -1, -1, 0);
        
        [UIView animateWithDuration:0.7 animations:^{
            self.topLabel.alpha = 1;
            self.bottomLabel.alpha = 1;
            self.categoryImageButton.transform = CGAffineTransformIdentity;
            self.chargeImage.layer.transform = CATransform3DIdentity;
        } completion:^(BOOL finished) {
//            [self updateConstraints];
            [self shake];
        }];
    } else {
        [self shake];
    }
}

- (void)updateSubviewsAlpha {
    if (_editAndDeleteBtnShowed) {
        self.labelContainer.alpha = 0;
        self.editeButton.alpha = 1;
        self.deleteButton.alpha = 1;
    } else {
        self.labelContainer.alpha = 1;
        self.editeButton.alpha = 0;
        self.deleteButton.alpha = 0;
    }
}

- (void)showEditAndDeleteBtn:(BOOL)showed animated:(BOOL)animated {
    _editAndDeleteBtnShowed = showed;
    [UIView animateWithDuration:(animated ? 0.25 : 0) animations:^{
        [self updateSubviewsAlpha];
        [self setNeedsUpdateConstraints];
        [self layoutIfNeeded];
    }];
}

#pragma mark - Private
- (void)tapAction {
    if (self.enterChargeDetailBlock) {
        self.enterChargeDetailBlock(self);
    }
}

- (void)updateAppearance {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
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

#pragma mark - Lazyloading
- (UIView *)verticalLine {
    if (!_verticalLine) {
        _verticalLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1 , self.height / 2)];
        _verticalLine.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor];
    }
    return _verticalLine;
}

- (UIButton *)categoryImageButton {
    if (!_categoryImageButton) {
        _categoryImageButton = [[UIButton alloc]init];
        _categoryImageButton.layer.borderWidth = 1;
        _categoryImageButton.layer.cornerRadius = kCategoryImageButtonRadius;
        _categoryImageButton.contentMode = UIViewContentModeCenter;
        _categoryImageButton.layer.masksToBounds = YES;
        [_categoryImageButton addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _categoryImageButton;
}

- (UIView *)labelContainer {
    if (!_labelContainer) {
        _labelContainer = [[UIView alloc] init];
        _labelContainer.backgroundColor = [UIColor clearColor];
        [_labelContainer addSubview:self.topLabel];
        [_labelContainer addSubview:self.bottomLabel];
        [_labelContainer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
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
        _bottomLabel.numberOfLines = 2;
        [_bottomLabel sizeToFit];
    }
    return _bottomLabel;
}

- (UIImageView *)chargeImage {
    if (!_chargeImage) {
        _chargeImage = [[UIImageView alloc] init];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick:)];
        singleTap.numberOfTapsRequired = 1;
        [_chargeImage addGestureRecognizer:singleTap];
    }
    return _chargeImage;
}

- (UIButton *)editeButton {
    if (!_editeButton) {
        _editeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editeButton setImage:[UIImage imageNamed:@"home_edit"] forState:UIControlStateNormal];
        @weakify(self);
        [[_editeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.editBlock) {
                self.editBlock(self);
            }
        }];
    }
    return _editeButton;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[UIImage imageNamed:@"home_delete"] forState:UIControlStateNormal];
        @weakify(self);
        [[_deleteButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [SSJCalenderHelper deleteChargeWithItem:self.item success:^{
                [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
                if (self.deleteBlock) {
                    self.deleteBlock(self);
                }
            } failure:^(NSError * _Nonnull error) {
                [SSJAlertViewAdapter showError:error];
            }];
        }];
    }
    return _deleteButton;
}

@end
