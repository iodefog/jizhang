//
//  SSJBooksTransferSelectView.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBooksTransferSelectView.h"

#import "SSJBooksView.h"

@interface SSJBooksTransferSelectView()

@property (nonatomic, strong) SSJBooksView *transferBooksView;

@property (nonatomic, strong) UILabel *chargeCountTitleLab;

@property (nonatomic, strong) UILabel *chargeCountLab;

@property (nonatomic, strong) UILabel *bookTypeTitleLab;

@property (nonatomic, strong) UILabel *bookTypeLab;

@property (nonatomic, strong) UIImageView *transferImage;

@property (nonatomic, strong) UIImageView *arrowImage;

@property (nonatomic) SSJBooksTransferViewType type;

@end


@implementation SSJBooksTransferSelectView

- (instancetype)initWithFrame:(CGRect)frame type:(SSJBooksTransferViewType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        [self addSubview:self.transferBooksView];
        [self addSubview:self.chargeCountTitleLab];
        [self addSubview:self.chargeCountLab];
        [self addSubview:self.bookTypeTitleLab];
        [self addSubview:self.bookTypeLab];
        [self addSubview:self.arrowImage];
    }
    return self;
}


- (void)updateConstraints {
    
    [self.transferBooksView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 110));
        make.top.mas_equalTo(self.mas_top).offset(15);
        make.centerX.mas_equalTo(self);
    }];
    
    
    [self.chargeCountTitleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(-29);
        make.left.mas_equalTo(32);
    }];
    
    [self.chargeCountLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.chargeCountTitleLab.mas_centerY);
        make.left.mas_equalTo(self.chargeCountTitleLab.mas_right).offset(5);
    }];
    
    
    [self.bookTypeTitleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(-29);
        make.right.mas_equalTo(self.bookTypeLab.mas_left).offset(-5);
    }];
    
    [self.bookTypeLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bookTypeTitleLab.mas_centerY);
        make.right.mas_equalTo(self.mas_right).offset(-32);
    }];
    
    
    [self.arrowImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.right.mas_equalTo(self.mas_left).offset(-15);
    }];

    
    [super updateConstraints];
}

- (UILabel *)chargeCountTitleLab {
    if (!_chargeCountTitleLab) {
        _chargeCountTitleLab = [[UILabel alloc] init];
        _chargeCountTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _chargeCountTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _chargeCountTitleLab.text = @"账本流水：";
    }
    return _chargeCountTitleLab;
}

- (UILabel *)chargeCountLab {
    if (!_chargeCountLab) {
        _chargeCountLab = [[UILabel alloc] init];
        _chargeCountLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _chargeCountLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _chargeCountLab;
}

- (UILabel *)bookTypeLab {
    if (!_bookTypeLab) {
        _bookTypeLab = [[UILabel alloc] init];
        _bookTypeLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _bookTypeLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _bookTypeLab;
}

- (UILabel *)bookTypeTitleLab {
    if (!_bookTypeTitleLab) {
        _bookTypeTitleLab = [[UILabel alloc] init];
        _bookTypeTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _bookTypeTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _bookTypeTitleLab.text = @"账本属性：";
    }
    return _bookTypeTitleLab;
}


- (SSJBooksView *)transferBooksView {
    if (!_transferBooksView) {
        _transferBooksView = [[SSJBooksView alloc] init];
    }
    return _transferBooksView;
}


- (UIImageView *)arrowImage {
    if (!_arrowImage) {
        _arrowImage = [[UIImageView alloc] init];
        _arrowImage.image = [[UIImage imageNamed:@"book_transfer_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _arrowImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor];
    }
    return _arrowImage;
}

- (void)setBooksTypeItem:(__kindof SSJBaseCellItem<SSJBooksItemProtocol> *)booksTypeItem {
    _booksTypeItem = booksTypeItem;
    self.transferBooksView.booksTypeItem = _booksTypeItem;
    self.bookTypeLab.text = [_booksTypeItem parentName];

    
    [self setNeedsUpdateConstraints];
}

- (void)setChargeCount:(NSNumber *)chargeCount {
    _chargeCount = chargeCount;
    self.chargeCountLab.text = [NSString stringWithFormat:@"%@条",chargeCount];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
