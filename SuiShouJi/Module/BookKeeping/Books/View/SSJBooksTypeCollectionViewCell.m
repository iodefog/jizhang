//
//  SSJBooksTypeCollectionViewCell.m
//  SuiShouJi
//
//  Created by ricky on 16/5/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBooksTypeCollectionViewCell.h"

static const CGFloat kCornerRadius = 10.f;

@interface SSJBooksTypeCollectionViewCell()

@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) UIView *seperatorLineView;

@property(nonatomic, strong) UIImageView *lineImage;

@property(nonatomic, strong) UIImageView *selectImageView;

@property(nonatomic, strong) CALayer *booksIcionImage;

@property (nonatomic, strong) UIView *mask;

@property (nonatomic, strong) UIImageView *icon;

@end

@implementation SSJBooksTypeCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.seperatorLineView];
        [self.contentView addSubview:self.lineImage];
        [self.contentView addSubview:self.selectImageView];
        [self.contentView.layer addSublayer:self.booksIcionImage];
        [self.contentView addSubview:self.mask];
        self.clipsToBounds = NO;
        self.layer.cornerRadius = kCornerRadius;
    }
    return self;
}

- (void)dealloc {
    [self removeOberver];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.seperatorLineView.size = CGSizeMake(2, self.height);
    self.seperatorLineView.leftTop = CGPointMake(22, 0);
    if (self.titleLabel.text.length) {
        if (self.titleLabel.text.length >= 4) {
            self.titleLabel.height = [[self.titleLabel.text substringWithRange:NSMakeRange(0, 1)] sizeWithAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2]}].height * 4;
        }else{
            self.titleLabel.height = [[self.titleLabel.text substringWithRange:NSMakeRange(0, 1)] sizeWithAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2]}].height * self.titleLabel.text.length;
        }
    }
    float maxWitdh = 0;
    for (int i = 0; i < self.titleLabel.text.length; i ++) {
        float textWidth = [[self.titleLabel.text substringWithRange:NSMakeRange(i, 1)] sizeWithAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2]}].width;
        if (textWidth > maxWitdh) {
            maxWitdh = textWidth;
        }
    }
    self.titleLabel.width = maxWitdh;
    self.titleLabel.centerX = self.width - (self.width - 24) / 2;
    self.titleLabel.centerY = self.height / 2;
    self.lineImage.size = CGSizeMake(7, 56);
    self.lineImage.center = CGPointMake(12, self.height / 2);
    self.selectImageView.rightBottom = CGPointMake(self.width, self.height - 10);
    if (!self.item.booksId.length) {
        self.booksIcionImage.position = CGPointMake(self.contentView.width - 16, self.contentView.height - 16);
    }else{
        self.booksIcionImage.position = CGPointMake(self.contentView.width - 21, self.contentView.height - 21);
    }
    
    self.mask.frame = self.contentView.bounds;
    self.icon.center = CGPointMake(self.mask.width * 0.5, self.mask.height * 0.5);
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    [self updateAppearance];
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

-(UIView *)seperatorLineView{
    if (!_seperatorLineView) {
        _seperatorLineView = [[UIView alloc]init];
        _seperatorLineView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.12];
    }
    return _seperatorLineView;
}

-(UIImageView *)lineImage{
    if (!_lineImage) {
        _lineImage = [[UIImageView alloc]init];
        _lineImage.image = [UIImage imageNamed:@"zhangben_bian"];
    }
    return _lineImage;
}

-(UIImageView *)selectImageView{
    if (!_selectImageView) {
        _selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 18, 9)];
        _selectImageView.image = [UIImage imageNamed:@"zhangben_mark"];
    }
    return _selectImageView;
}

-(CALayer *)booksIcionImage{
    if (!_booksIcionImage) {
        _booksIcionImage = [CALayer layer];
        _booksIcionImage.size = CGSizeMake(32, 32);
//        _booksIcionImage.backgroundColor = [UIColor blackColor].CGColor;
        _booksIcionImage.position = CGPointMake(self.width / 2, self.height / 2);
    }
    return _booksIcionImage;
}

- (UIView *)mask {
    if (!_mask) {
        _mask = [[UIView alloc] init];
        _mask.backgroundColor = [UIColor blackColor];
        _mask.alpha = 0.6;
        _mask.layer.cornerRadius = kCornerRadius;
        _mask.clipsToBounds = YES;
        [_mask addSubview:self.icon];
    }
    return _mask;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"book_edit_icon"]];
    }
    return _icon;
}

-(void)setItem:(SSJBooksTypeItem *)item{
    [self removeOberver];
    _item = item;
    [self addObesever];
    [self updateAppearance];
}

- (void)removeOberver{
    [_item removeObserver:self forKeyPath:@"selectToEdite"];
    [_item removeObserver:self forKeyPath:@"booksColor"];
    [_item removeObserver:self forKeyPath:@"booksName"];
    [_item removeObserver:self forKeyPath:@"booksIcoin"];
    [_item removeObserver:self forKeyPath:@"editeModel"];
}

- (void)addObesever{
    [_item addObserver:self forKeyPath:@"selectToEdite" options:NSKeyValueObservingOptionNew context:NULL];
    [_item addObserver:self forKeyPath:@"booksColor" options:NSKeyValueObservingOptionNew context:NULL];
    [_item addObserver:self forKeyPath:@"booksName" options:NSKeyValueObservingOptionNew context:NULL];
    [_item addObserver:self forKeyPath:@"booksIcoin" options:NSKeyValueObservingOptionNew context:NULL];
    [_item addObserver:self forKeyPath:@"editeModel" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)updateAppearance{
//    self.backgroundColor = [UIColor ssj_colorWithHex:_item.booksColor];
    self.titleLabel.text = _item.booksName;
    [self.titleLabel sizeToFit];
    self.booksIcionImage.contents = (id)[[UIImage imageNamed:_item.parentIcon] ssj_imageWithColor:[UIColor ssj_colorWithHex:@"#000000" alpha:0.15]].CGImage;
    if (self.item.booksId.length) {
        self.booksIcionImage.transform = CATransform3DMakeRotation(-M_PI_4, 0, 0, 1);
    }else{
        self.booksIcionImage.transform = CATransform3DIdentity;
    }
    self.mask.hidden = !_item.editeModel;
    [self setNeedsLayout];
}

-(void)setEditeModel:(BOOL)editeModel{
    _editeModel = editeModel;
}

-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    self.selectImageView.hidden = !_isSelected;
}

@end
