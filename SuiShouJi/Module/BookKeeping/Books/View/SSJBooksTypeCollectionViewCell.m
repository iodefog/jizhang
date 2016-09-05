//
//  SSJBooksTypeCollectionViewCell.m
//  SuiShouJi
//
//  Created by ricky on 16/5/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBooksTypeCollectionViewCell.h"

@interface SSJBooksTypeCollectionViewCell()

@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) UIView *seperatorLineView;

@property(nonatomic, strong) UIImageView *lineImage;

@property(nonatomic, strong) UIImageView *selectImageView;

@property(nonatomic, strong) CALayer *booksIcionImage;

@property(nonatomic, strong) UIButton *selectedButton;

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
        [self.contentView addSubview:self.selectedButton];
        [self.contentView.layer addSublayer:self.booksIcionImage];
        self.clipsToBounds = NO;
        self.layer.cornerRadius = 4.f;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.seperatorLineView.size = CGSizeMake(2, self.height);
    self.seperatorLineView.leftTop = CGPointMake(22, 0);
    if (self.titleLabel.text.length) {
        if (self.titleLabel.text.length >= 4) {
            self.titleLabel.height = [[self.titleLabel.text substringWithRange:NSMakeRange(0, 1)] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]}].height * 4;
        }else{
            self.titleLabel.height = [[self.titleLabel.text substringWithRange:NSMakeRange(0, 1)] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]}].height * self.titleLabel.text.length;
        }
    }
    self.titleLabel.width = [[self.titleLabel.text substringWithRange:NSMakeRange(0, 1)] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]}].width;
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
    if (self.item.booksId.length) {
        self.selectedButton.rightTop = CGPointMake(self.contentView.width , 0);
    }else{
        self.selectedButton.hidden = YES;
    }
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    [self updateAppearance];
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:18];
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

- (UIButton *)selectedButton{
    if (!_selectedButton) {
        _selectedButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 18, 18)];
        [_selectedButton addTarget:self action:@selector(selectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_selectedButton setImage:[UIImage imageNamed:@"book_xuanzhong"] forState:UIControlStateNormal];
        [_selectedButton setImage:[UIImage imageNamed:@"book_sel"] forState:UIControlStateSelected];
    }
    return _selectedButton;
}

- (void)selectButtonClicked:(id)sender{
    self.item.selectToEdite = !self.item.selectToEdite;
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
    self.backgroundColor = [UIColor ssj_colorWithHex:_item.booksColor];
    self.titleLabel.text = _item.booksName;
    [self.titleLabel sizeToFit];
    self.booksIcionImage.contents = (id)[[UIImage imageNamed:_item.booksIcoin] imageWithColor:[UIColor ssj_colorWithHex:@"#000000" alpha:0.15]].CGImage;
    if (self.item.booksId.length) {
        self.booksIcionImage.transform = CATransform3DMakeRotation(-M_PI_4, 0, 0, 1);
    }else{
        self.booksIcionImage.transform = CATransform3DIdentity;
    }
    self.selectedButton.hidden = !_item.editeModel;
    self.selectedButton.selected = _item.selectToEdite;
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
