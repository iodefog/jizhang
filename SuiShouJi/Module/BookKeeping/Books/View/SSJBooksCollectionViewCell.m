//
//  SSJBooksCollectionViewCell.m
//  SuiShouJi
//
//  Created by yi cai on 2017/5/16.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBooksCollectionViewCell.h"
#import "SSJBooksTypeItem.h"
#import "SSJShareBookItem.h"

static const CGFloat kBooksCornerRadius = 10.f;

@interface SSJBooksCollectionViewCell()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) CAShapeLayer *backLayer;

@property (nonatomic, strong) UILabel *nameLab;

@property (nonatomic, strong) UILabel *menberNumLab;

@property (nonatomic, strong) UIImageView *markImageView;

//@property (nonatomic, strong) UIView *mask;
//
//@property (nonatomic, strong) UIImageView *maskImageView;
/**<#注释#>*/
@property (nonatomic, strong) UIButton *maskButton;

@end

@implementation SSJBooksCollectionViewCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView.layer addSublayer:self.gradientLayer];
        [self.contentView.layer addSublayer:self.backLayer];
        [self.contentView addSubview:self.nameLab];
        [self.contentView addSubview:self.menberNumLab];
        [self.contentView addSubview:self.markImageView];
        [self.contentView addSubview:self.maskButton];
        [self setNeedsUpdateConstraints];
//        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setNeedsUpdateConstraints {
    [super setNeedsUpdateConstraints];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-11);
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(20);
    }];
    
    [self.menberNumLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.bottomMargin.mas_equalTo(-10);
    }];
    
    [self.markImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.top.mas_equalTo(self.contentView);
    }];
    
    [self.maskButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.right.mas_equalTo(self.contentView);
    }];

}

#pragma mark - Setter
- (void)setBooksTypeItem:(__kindof SSJBaseCellItem *)booksTypeItem {
    _booksTypeItem = booksTypeItem;
    if ([booksTypeItem isKindOfClass:[SSJBooksTypeItem class]]) {//个人账本
        SSJBooksTypeItem *privateBookItem = (SSJBooksTypeItem *)booksTypeItem;
        self.nameLab.text = privateBookItem.booksName;
        self.menberNumLab.hidden = YES;
        //当前选中账本的标记
        if ([privateBookItem.booksId isEqualToString:self.curretSelectedBookId]) {
            self.markImageView.hidden = NO;
        }else{
            self.markImageView.hidden = YES;
        }
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.gradientLayer.colors = @[(__bridge id)[UIColor brownColor].CGColor,(__bridge id)[UIColor lightGrayColor].CGColor];
        
        if (!privateBookItem.booksId.length && [privateBookItem.booksName isEqualToString:@"添加账本"]) {
            self.gradientLayer.hidden = YES;
            self.backLayer.hidden = NO;
            self.nameLab.textColor = [UIColor ssj_colorWithHex:@"666666"];
        } else {
            self.gradientLayer.hidden = NO;
            self.backLayer.hidden = YES;
            self.nameLab.textColor = [UIColor whiteColor];
        }
        
        self.maskButton.hidden = !privateBookItem.editeModel;
        [CATransaction commit];
    } else if ([booksTypeItem isKindOfClass:[SSJShareBookItem class]]) {//共享账本
        SSJShareBookItem *shareBookItem = (SSJShareBookItem *)booksTypeItem;
        self.nameLab.text = shareBookItem.booksName;
        self.menberNumLab.hidden = NO;
        //当前选中账本的标记
        if ([shareBookItem.booksId isEqualToString:self.curretSelectedBookId]) {
            self.markImageView.hidden = NO;
        }else{
            self.markImageView.hidden = YES;
        }
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.gradientLayer.colors = @[(__bridge id)[UIColor yellowColor].CGColor,(__bridge id)[UIColor purpleColor].CGColor];
        
        if (!shareBookItem.booksId.length && [shareBookItem.booksName isEqualToString:@"添加账本"]) {
            self.gradientLayer.hidden = YES;
            self.backLayer.hidden = NO;
            self.nameLab.textColor = [UIColor ssj_colorWithHex:@"666666"];
        } else {
            self.gradientLayer.hidden = NO;
            self.backLayer.hidden = YES;
            self.nameLab.textColor = [UIColor whiteColor];
        }
        self.maskButton.hidden = !shareBookItem.isEditing;
        [CATransaction commit];
    }
}


#pragma mark - Private
- (CGSize)sizeForItem {
    float collectionViewWith = SSJSCREENWITH * 0.8;
    float itemWidth;
    if (SSJSCREENWITH == 320) {
        itemWidth = (collectionViewWith - 24 - 30) / 3;
    }else{
        itemWidth = (collectionViewWith - 24 - 45) / 3;
    }
    return CGSizeMake(itemWidth, itemWidth * 1.3);
}

#pragma mark - Lazy
- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        CGRect itemRect = CGRectMake(0, 0, [self sizeForItem].width, [self sizeForItem].height);
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = itemRect;
        CAShapeLayer *sharpLayer = [CAShapeLayer layer];
        sharpLayer.path = [UIBezierPath bezierPathWithRoundedRect:itemRect cornerRadius:kBooksCornerRadius].CGPath;
        _gradientLayer.mask = sharpLayer;
    }
    return _gradientLayer;
}

- (CAShapeLayer *)backLayer {
    if (!_backLayer) {
        CGRect itemRect = CGRectMake(0, 0, [self sizeForItem].width, [self sizeForItem].height);
        _backLayer = [CAShapeLayer layer];
        _backLayer.path = [UIBezierPath bezierPathWithRoundedRect:itemRect cornerRadius:kBooksCornerRadius].CGPath;
        _backLayer.strokeColor = [UIColor ssj_colorWithHex:@"666666"].CGColor;
        _backLayer.borderWidth = 1;
        _backLayer.fillColor = [UIColor whiteColor].CGColor;
    }
    return _backLayer;
}

- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.backgroundColor = [UIColor clearColor];
        _nameLab.numberOfLines = 0;
        _nameLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _nameLab.textColor = [UIColor whiteColor];
    }
    return _nameLab;
}

- (UILabel *)menberNumLab {
    if (!_menberNumLab) {
        _menberNumLab = [[UILabel alloc] init];
        _menberNumLab.backgroundColor = [UIColor clearColor];
        _menberNumLab.text = @"2人";
        _menberNumLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _menberNumLab.textColor = [UIColor whiteColor];
    }
    return _menberNumLab;
}

- (UIImageView *)markImageView {
    if (!_markImageView) {
        _markImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zhangben_mark"]];
        _markImageView.userInteractionEnabled = YES;
    }
    return _markImageView;
}

- (UIButton *)maskButton {
    if (!_maskButton) {
        _maskButton = [[UIButton alloc] init];
        _maskButton.backgroundColor = [UIColor ssj_colorWithHex:@"000000" alpha:0.5];
        [_maskButton setImage:[UIImage imageNamed:@"book_edit_icon"] forState:UIControlStateNormal];
        _maskButton.layer.cornerRadius = kBooksCornerRadius;
        _maskButton.clipsToBounds = YES;
        [_maskButton addTarget:self action:@selector(editButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _maskButton;
}

#pragma mark - Action
- (void)editButtonClicked:(UIButton *)button {
    if (self.editBookAction) {
        self.editBookAction();
    }
}

@end
