 //
//  SSJCreditCardEditeCell.m
//  SuiShouJi
//
//  Created by ricky on 16/8/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCreditCardEditeCell.h"

@interface SSJCreditCardEditeCell()

@property(nonatomic, strong) UIImageView *cellImage;

@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic,strong) UIImageView *cellDetailImage;

@property(nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) CAShapeLayer *arrow;

@end

@implementation SSJCreditCardEditeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.isExpand = NO;
        [self.contentView addSubview:self.cellImage];
        [self.contentView addSubview:self.textInput];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailLabel];
        [self.contentView addSubview:self.cellDetailImage];
        [self.contentView addSubview:self.subTitleLabel];
        [self.contentView.layer addSublayer:self.arrow];
        [self.contentView addSubview:self.containerView];
        [self.contentView.layer addSublayer:self.gradientLayer];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //分割线
    for (UIView *subview in self.contentView.superview.subviews) {
        if ([NSStringFromClass(subview.class) hasSuffix:@"SeparatorView"]) {
            subview.hidden = NO;
        }
    }
    switch (self.type) {
        case SSJCreditCardCellTypeTextField:{
            self.cellImage.left = 15;
            self.cellImage.centerY = self.contentView.height / 2;
            self.accessoryView.centerY = self.cellImage.centerY;
            self.titleLabel.left = self.cellImage.image ? self.cellImage.right + 10 : 15;
            self.titleLabel.centerY = self.contentView.height / 2;
            self.textInput.size = CGSizeMake(self.contentView.width - self.titleLabel.right - 15, self.contentView.height);
            self.textInput.left = self.titleLabel.right + 10;
            self.textInput.centerY = self.contentView.height / 2;
            self.textInput.hidden = NO;
            self.titleLabel.hidden = NO;
            self.detailLabel.hidden = YES;
            self.cellDetailImage.hidden = YES;
            self.subTitleLabel.hidden = YES;
            self.gradientLayer.hidden = YES;
            self.arrow.hidden = YES;
            self.containerView.hidden = YES;
        }
            break;
            
        case SSJCreditCardCellTypeDetail:{
            self.cellImage.left = 15;
            self.cellImage.centerY = self.contentView.height / 2;
            self.accessoryView.centerY = self.cellImage.centerY;
            self.titleLabel.left = self.cellImage.image ? self.cellImage.right + 10 : 15;
            self.titleLabel.centerY = self.contentView.height / 2;
            if (self.contentView.width == self.width) {
                if (self.detailLabel.width > self.contentView.width - 15 - self.titleLabel.right) {
                    self.detailLabel.width = self.contentView.width - 15 - self.titleLabel.right;
                    self.detailLabel.adjustsFontSizeToFitWidth = YES;
                }
            }else{
                if (self.detailLabel.width > self.contentView.width - self.titleLabel.right) {
                    self.detailLabel.width = self.contentView.width - self.titleLabel.right;
                    self.detailLabel.adjustsFontSizeToFitWidth = YES;
                }
            }
            if (self.contentView.width == self.width) {
                self.detailLabel.right = self.contentView.width - 15;
            }else{
                self.detailLabel.right = self.contentView.width;
            }
            self.detailLabel.centerY = self.contentView.height /  2;
            if (!self.cellAtrributedDetail.length) {
                self.detailLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
            }
            self.cellDetailImage.right = self.detailLabel.left - 15;
            self.cellDetailImage.centerY = self.contentView.height /  2;
            self.titleLabel.hidden = NO;
            self.cellDetailImage.hidden = NO;
            self.textInput.hidden = YES;
            self.subTitleLabel.hidden = YES;
            self.gradientLayer.hidden = YES;
            self.detailLabel.hidden = NO;
            self.arrow.hidden = YES;
            self.containerView.hidden = YES;
        }
            break;
            
        case SSJCreditCardCellTypeassertedDetail:{
            self.cellImage.left = 15;
            self.cellImage.centerY = self.contentView.height / 2;
            self.accessoryView.centerY = self.cellImage.centerY;
            self.titleLabel.left = self.cellImage.image ? self.cellImage.right + 10 : 15;
            self.titleLabel.centerY = self.contentView.height / 2;
            if (self.contentView.width == self.width) {
                if (self.detailLabel.width > self.contentView.width - 15 - self.titleLabel.right) {
                    self.detailLabel.width = self.contentView.width - 15 - self.titleLabel.right;
                    self.detailLabel.adjustsFontSizeToFitWidth = YES;
                }
            }else{
                if (self.detailLabel.width > self.contentView.width - self.titleLabel.right) {
                    self.detailLabel.width = self.contentView.width - self.titleLabel.right;
                    self.detailLabel.adjustsFontSizeToFitWidth = YES;
                }
            }
            if (self.contentView.width == self.width) {
                self.detailLabel.right = self.contentView.width - 15;
            }else{
                self.detailLabel.right = self.contentView.width;
            }
            self.detailLabel.centerY = self.contentView.height /  2;
            if (!self.cellAtrributedDetail.length) {
                self.detailLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
            }
            self.cellDetailImage.right = self.detailLabel.left - 10;
            self.cellDetailImage.centerY = self.contentView.height /  2;
            self.titleLabel.hidden = NO;
            self.cellDetailImage.hidden = NO;
            self.textInput.hidden = YES;
            self.subTitleLabel.hidden = YES;
            self.gradientLayer.hidden = YES;
            self.detailLabel.hidden = NO;
            self.arrow.hidden = YES;
            self.containerView.hidden = YES;
        }
            break;
            
        case SSJCreditCardCellTypeSubTitle:{
            self.cellImage.left = 15;
            self.cellImage.top = 10;
            self.accessoryView.centerY = self.cellImage.centerY;
            self.titleLabel.left = self.cellImage.image ? self.cellImage.right + 10 : 15;
            self.titleLabel.centerY = self.cellImage.centerY;
            self.subTitleLabel.top = self.titleLabel.bottom + 10;
            self.subTitleLabel.left = self.titleLabel.left;
            self.titleLabel.hidden = NO;
            self.cellDetailImage.hidden = NO;
            self.textInput.hidden = YES;
            self.subTitleLabel.hidden = NO;
            self.gradientLayer.hidden = YES;
            self.detailLabel.hidden = NO;
            self.arrow.hidden = YES;
            self.containerView.hidden = YES;
        }
            break;
            
        case SSJCreditCardCellColorSelect:{
            self.cellImage.left = 15;
            self.cellImage.centerY = self.contentView.height / 2;
            self.accessoryView.centerY = self.cellImage.centerY;
            self.titleLabel.left = self.cellImage.image ? self.cellImage.right + 10 : 15;
            self.titleLabel.centerY = self.contentView.height / 2;
            self.gradientLayer.position = CGPointMake(0, self.height / 2);
            if (self.contentView.width == self.width) {
                self.gradientLayer.right = self.contentView.width - 15;
            }else{
                self.gradientLayer.right = self.contentView.width;
            }
            self.titleLabel.hidden = NO;
            self.detailLabel.hidden = YES;
            self.cellDetailImage.hidden = YES;
            self.gradientLayer.hidden = NO;

            self.textInput.hidden = YES;
            self.subTitleLabel.hidden = YES;
            self.arrow.hidden = YES;
            self.containerView.hidden = YES;
        }
            break;
            
        case SSJCreditCardBalanceCell:{
            self.cellImage.left = 15;
            self.cellImage.centerY = self.contentView.height / 2;
            self.accessoryView.centerY = self.cellImage.centerY;
            self.titleLabel.left = self.cellImage.image ? self.cellImage.right + 10 : 15;
            self.titleLabel.centerY = self.contentView.height / 2;
            self.textInput.hidden = NO;
            self.titleLabel.hidden = NO;
            self.detailLabel.hidden = YES;
            self.cellDetailImage.hidden = YES;
            self.subTitleLabel.hidden = YES;
            self.gradientLayer.hidden = YES;
            self.arrow.hidden = NO;
            self.containerView.hidden = NO;
            self.arrow.left = self.titleLabel.right + 10;
            self.arrow.position = CGPointMake(self.arrow.position.x, self.contentView.height / 2);
            self.containerView.size = CGSizeMake(self.arrow.right - self.titleLabel.left, self.titleLabel.height);
            self.containerView.left = self.titleLabel.left;
            self.containerView.centerY = self.contentView.height / 2;
            self.textInput.size = CGSizeMake(self.contentView.width - self.containerView.right - 15, self.contentView.height) ;
            self.textInput.centerY = self.contentView.height / 2;
            self.textInput.left = self.containerView.right + 10;
        }
            break;
            
        default:
            break;
    }
}

- (UIImageView *)cellImage{
    if (!_cellImage) {
        _cellImage = [[UIImageView alloc]init];
        _cellImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _cellImage;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel{
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc]initWithFrame:CGRectZero];
//        _detailLabel.adjustsFontSizeToFitWidth = YES;
        _detailLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _detailLabel;
}

- (UILabel *)subTitleLabel{
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _subTitleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _subTitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _subTitleLabel;
}

- (UIImageView *)cellDetailImage{
    if (!_cellDetailImage) {
        _cellDetailImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    }
    return _cellDetailImage;
}

- (UITextField *)textInput{
    if (!_textInput) {
        _textInput = [[UITextField alloc]init];
        _textInput.textAlignment = NSTextAlignmentRight;
        _textInput.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _textInput.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _textInput;
}


- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.startPoint = CGPointMake(0, 0.5);
        _gradientLayer.endPoint = CGPointMake(1, 0.5);
        _gradientLayer.size = CGSizeMake(50, 30);
        _gradientLayer.cornerRadius = 8.f;
    }
    return _gradientLayer;
}

- (CAShapeLayer *)arrow {
    if (!_arrow) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointZero];
        [path addLineToPoint:CGPointMake(5, 5)];
        [path addLineToPoint:CGPointMake(10, 0)];
        
        _arrow = [CAShapeLayer layer];
        _arrow.size = CGSizeMake(10, 5);
        _arrow.path = path.CGPath;
        _arrow.lineWidth = 1;
        _arrow.fillColor = SSJ_MAIN_COLOR.CGColor;
    }
    return _arrow;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.userInteractionEnabled = YES;
        [_containerView addGestureRecognizer:self.tapGesture];
    }
    return _containerView;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBalanceTypeSelectView)];
    }
    return _tapGesture;
}

- (void)setColorItem:(SSJFinancingGradientColorItem *)colorItem {
    if (!colorItem.startColor) return;
    _gradientLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:colorItem.startColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:colorItem.endColor].CGColor];
}


- (void)setCellImageName:(NSString *)cellImageName{
    _cellImageName = cellImageName;
    self.cellImage.image = [[UIImage imageNamed:_cellImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.cellImage sizeToFit];
}

- (void)setCellDetailImageName:(NSString *)cellDetailImageName{
    _cellDetailImageName = cellDetailImageName;
    self.cellDetailImage.image = [UIImage imageNamed:_cellDetailImageName];
    [self.cellDetailImage sizeToFit];
}

- (void)setCellTitle:(NSString *)cellTitle {
    _cellTitle = cellTitle;
    self.titleLabel.text = _cellTitle;
    [self.titleLabel sizeToFit];
}

- (void)setCellSubTitle:(NSString *)cellSubTitle {
    _cellSubTitle = cellSubTitle;
    self.subTitleLabel.text = _cellSubTitle;
    [self.subTitleLabel sizeToFit];
}

- (void)setType:(SSJCreditCardCellType)type {
    _type = type;
    [self setNeedsLayout];
}

- (void)setCellDetail:(NSString *)cellDetail {
    _cellDetail = cellDetail;
    self.detailLabel.text = _cellDetail;
    self.detailLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    [self.detailLabel sizeToFit];
}

- (void)setCellAtrributedDetail:(NSAttributedString *)cellAtrributedDetail {
    _cellAtrributedDetail = cellAtrributedDetail;
    self.detailLabel.attributedText = _cellAtrributedDetail;
    [self.detailLabel sizeToFit];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    _cellImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _subTitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _textInput.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _arrow.fillColor = SSJ_MAIN_COLOR.CGColor;
}

- (void)showBalanceTypeSelectView {
    self.isExpand = !self.isExpand;
    if (self.isExpand) {
        self.arrow.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
    } else {
        self.arrow.transform = CATransform3DIdentity;
    }
    if (self.showBalanceTypeSelectViewBlock) {
        self.showBalanceTypeSelectViewBlock(self.arrow.position,self.isExpand,self);
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
