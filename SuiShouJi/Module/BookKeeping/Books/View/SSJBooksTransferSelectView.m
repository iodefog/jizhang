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

@property (nonatomic, strong) UILabel *transferInLab;

@property (nonatomic, strong) UILabel *transferInNameLab;

@property (nonatomic, strong) UIImageView *transferImage;

@property (nonatomic, strong) UIImageView *arrowImage;

@property (nonatomic, strong) SSJBooksView *transferInBookView;

@property (nonatomic, strong) SSJBooksView *transferOutBookView;

@property (nonatomic, strong) UIButton *transferInButton;

@property (nonatomic) SSJBooksTransferViewType type;

@end


@implementation SSJBooksTransferSelectView

- (instancetype)initWithFrame:(CGRect)frame type:(SSJBooksTransferViewType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        if (type == SSJBooksTransferViewTypeTransferOut) {
            [self addSubview:self.transferInBookView];
            [self addSubview:self.chargeCountTitleLab];
            [self addSubview:self.chargeCountLab];
            [self addSubview:self.bookTypeTitleLab];
            [self addSubview:self.bookTypeLab];
        } else if (type == SSJBooksTransferViewTypeTransferIn) {
            [self addSubview:self.transferInButton];
            [self.transferInButton addSubview:self.transferInLab];
            [self.transferInButton addSubview:self.transferInNameLab];            
            [self.transferInButton addSubview:self.arrowImage];
        }
    }
    return self;
}

- (void)updateConstraints {
    
    if (self.type == SSJBooksTransferViewTypeTransferOut) {        
        [self.transferOutBookView mas_updateConstraints:^(MASConstraintMaker *make) {
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

    } else if (self.type == SSJBooksTransferViewTypeTransferIn) {
        [self.transferInBookView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(15);
            make.size.mas_equalTo(CGSizeMake(80, 110));
            make.centerX.mas_equalTo(self);
        }];
        
        [self.transferInButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom);
            make.width.mas_equalTo(self);
            make.height.mas_equalTo(55);
            make.left.mas_equalTo(self);
        }];

        [self.transferInLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.transferInButton.mas_centerY);
            make.left.mas_equalTo(self.transferInButton.mas_left).offset(15);
        }];

        [self.transferInNameLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.transferInButton.mas_centerY);
            make.right.mas_equalTo(self.arrowImage.mas_left).offset(-10);
        }];
        
        [self.arrowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.transferInButton.mas_centerY);
            make.right.mas_equalTo(self.transferInButton.mas_right).offset(-15);
        }];

        [self.transferInBookView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80, 110));
            make.top.mas_equalTo(self.mas_top).offset(15);
            make.centerX.mas_equalTo(self);
        }];
    }
    
    [super updateConstraints];
}

- (UILabel *)chargeCountTitleLab {
    if (!_chargeCountTitleLab) {
        _chargeCountTitleLab = [[UILabel alloc] init];
        _chargeCountTitleLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_4];
        _chargeCountTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _chargeCountTitleLab.text = @"账本流水：";
    }
    return _chargeCountTitleLab;
}

- (UILabel *)chargeCountLab {
    if (!_chargeCountLab) {
        _chargeCountLab = [[UILabel alloc] init];
        _chargeCountLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_3];
        _chargeCountLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _chargeCountLab;
}

- (UILabel *)bookTypeLab {
    if (!_bookTypeLab) {
        _bookTypeLab = [[UILabel alloc] init];
        _bookTypeLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_3];
        _bookTypeLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _bookTypeLab;
}

- (UILabel *)bookTypeTitleLab {
    if (!_bookTypeTitleLab) {
        _bookTypeTitleLab = [[UILabel alloc] init];
        _bookTypeTitleLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_4];
        _bookTypeTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _bookTypeTitleLab.text = @"账本属性：";
    }
    return _bookTypeTitleLab;
}

- (UILabel *)transferInLab {
    if (!_transferInLab) {
        _transferInLab = [[UILabel alloc] init];
        _transferInLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_3];
        _transferInLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _transferInLab.text = @"请选择账本";
    }
    return _transferInLab;
}


- (UILabel *)transferInNameLab {
    if (!_transferInNameLab) {
        _transferInNameLab = [[UILabel alloc] init];
        _transferInNameLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_3];
        _transferInNameLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _transferInNameLab;
}

- (UIImageView *)arrowImage {
    if (!_arrowImage) {
        _arrowImage = [[UIImageView alloc] init];
        _arrowImage.image = [[UIImage imageNamed:@"book_transfer_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _arrowImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor];
    }
    return _arrowImage;
}

- (UIButton *)transferInButton {
    if (!_transferInButton) {
        _transferInButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_transferInButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor]];
        [_transferInButton ssj_setBorderWidth:1];
        [_transferInButton ssj_setBorderStyle:SSJBorderStyleTop];
    }
    return _transferInButton;
}

- (void)setBooksTypeItem:(__kindof SSJBaseCellItem<SSJBooksItemProtocol> *)booksTypeItem {
    _booksTypeItem = booksTypeItem;
    if (self.type == SSJBooksTransferViewTypeTransferOut) {
        self.bookTypeLab.text = [_booksTypeItem parentName];
        self.transferOutBookView.booksTypeItem = _booksTypeItem;
    } else if (self.type == SSJBooksTransferViewTypeTransferIn) {
        self.transferInBookView.booksTypeItem = _booksTypeItem;
        self.transferInNameLab.text = _booksTypeItem.booksName;
    }
    
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
