//
//  SSJSearchHistoryCell.m
//  SuiShouJi
//
//  Created by ricky on 16/9/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSearchHistoryCell.h"
#import "SSJChargeSearchingStore.h"

@interface SSJSearchHistoryCell()

@property(nonatomic, strong) UILabel *titleLab;


@property(nonatomic, strong) UIButton *deleteButton;
@end

@implementation SSJSearchHistoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.titleLab];
        [self.contentView addSubview:self.deleteButton];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.titleLab.centerY = self.height / 2;
    self.titleLab.left = 10;
    self.deleteButton.centerY = self.height / 2;
    self.deleteButton.right = self.width - 10;
}

- (UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc]init];
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _titleLab;
}

- (UIButton *)deleteButton{
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_deleteButton setImage:[UIImage imageNamed:@"bt_delete"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (void)setCellItem:(SSJBaseCellItem *)cellItem{
    [super setCellItem:cellItem];
    if (![cellItem isKindOfClass:[SSJSearchHistoryItem class]]) {
        return;
    }
    SSJSearchHistoryItem *item = (SSJSearchHistoryItem *)cellItem;
    self.titleLab.text = item.searchHistory;
    [self.titleLab sizeToFit];
}

- (void)deleteButtonClicked:(id)sender{
    SSJSearchHistoryItem *item = (SSJSearchHistoryItem *)self.cellItem;
    __weak typeof(self) weakSelf = self;
    if ([SSJChargeSearchingStore deleteSearchHistoryItem:item error:NULL]) {
        if (weakSelf.deleteAction) {
            weakSelf.deleteAction(item);
        }
    };
}

- (void)updateCellAppearanceAfterThemeChanged{
    [super updateCellAppearanceAfterThemeChanged];
    self.titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
