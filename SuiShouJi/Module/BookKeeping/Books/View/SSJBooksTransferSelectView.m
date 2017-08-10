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

@property (nonatomic, strong) UILabel *booksSelectLab;

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
        [self addSubview:self.booksSelectLab];
        if (type == SSJBooksTransferViewTypeTransferIn) {
            self.booksSelectLab.text = @"请选择迁入账本";
        } else {
            self.booksSelectLab.text = @"请选择迁出账本";
        }
    }
    return self;
}

- (void)updateConstraints {
    
    [self.transferBooksView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 110));
        make.left.mas_equalTo(self).offset(24);
        make.centerY.mas_equalTo(self);
    }];
    
    
    [self.chargeCountTitleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.transferBooksView.mas_right).offset(26);
        make.bottom.mas_equalTo(self.mas_centerY).offset(-12);
    }];
    
    [self.chargeCountLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.chargeCountTitleLab.mas_centerY);
        make.left.mas_equalTo(self.chargeCountTitleLab.mas_right).offset(4);
    }];
    
    
    [self.bookTypeTitleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.transferBooksView.mas_right).offset(26);
        make.top.mas_equalTo(self.mas_centerY).offset(12);
    }];
    
    [self.bookTypeLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bookTypeTitleLab.mas_centerY);
        make.left.mas_equalTo(self.bookTypeTitleLab.mas_right).offset(4);
    }];
    
    
    [self.arrowImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.right.mas_equalTo(self.mas_right).offset(-15);
    }];

    [self.booksSelectLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(self.transferBooksView.mas_right).offset(25);
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

- (UILabel *)booksSelectLab {
    if (!_booksSelectLab) {
        _booksSelectLab = [[UILabel alloc] init];
        _booksSelectLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _booksSelectLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _booksSelectLab;
}

- (void)setBooksTypeItem:(__kindof SSJBaseCellItem<SSJBooksItemProtocol> *)booksTypeItem {
    _booksTypeItem = booksTypeItem;
    if (_booksTypeItem) {
        self.transferBooksView.booksTypeItem = _booksTypeItem;
        if (_booksTypeItem.booksCategory == SSJBooksCategoryPublic) {
            self.bookTypeLab.text = @"共享账本";
        } else if (_booksTypeItem.booksCategory == SSJBooksCategoryPersional) {
            self.bookTypeLab.text = @"个人账本";
        }
        self.bookTypeLab.hidden = NO;
        self.bookTypeTitleLab.hidden = NO;
        self.chargeCountLab.hidden = NO;
        self.chargeCountTitleLab.hidden = NO;
        self.booksSelectLab.hidden = YES;
    } else {
        self.transferBooksView.booksTypeItem = _booksTypeItem;
        self.bookTypeLab.hidden = YES;
        self.bookTypeTitleLab.hidden = YES;
        self.chargeCountLab.hidden = YES;
        self.chargeCountTitleLab.hidden = YES;
        self.booksSelectLab.hidden = NO;
    } 
    
    [self setNeedsUpdateConstraints];
}

- (void)setSelectable:(BOOL)selectable {
    _selectable = selectable;
    self.arrowImage.hidden = !_selectable;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_selectable) {
        if (self.transferInSelectButtonClick) {
            self.transferInSelectButtonClick();
        }
    }
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
