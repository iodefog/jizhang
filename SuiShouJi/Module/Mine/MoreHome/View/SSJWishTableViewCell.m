//
//  SSJWishTableViewCell.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishTableViewCell.h"

#import "SSJWishDefItem.h"

@interface SSJWishTableViewCell ()

@property (nonatomic, strong) UIButton *accessoryBtn;
@end

@implementation SSJWishTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self updateCellAppearanceAfterThemeChanged];
    }
    return self;
}

+ (SSJWishTableViewCell *)cellWithTableView:(__kindof UITableView *)tableView {
    static NSString *cellId = @"SSJMakeWishViewControllerCellId";
    SSJWishTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SSJWishTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return cell;

}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    if ([cellItem isKindOfClass:[SSJWishDefItem class]]) {
        SSJWishDefItem *item = cellItem;
        if (item.wishCount.length) {
            self.accessoryView = self.accessoryBtn;
            [self.accessoryBtn setTitle:item.wishCount forState:UIControlStateNormal];
            [self.accessoryBtn sizeToFit];
        } else {
            self.accessoryView = nil;
        }
        self.textLabel.text = item.wishName;
    }
}


- (void)updateCellAppearanceAfterThemeChanged {
    self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    [self.accessoryBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] forState:UIControlStateNormal];
}

- (UIButton *)accessoryBtn {
    if (!_accessoryBtn) {
        _accessoryBtn = [[UIButton alloc] init];
        [_accessoryBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -4, 0, 4)];
        [_accessoryBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, -4)];
        [_accessoryBtn setImage:[UIImage imageNamed:@"wish_readnum"] forState:UIControlStateNormal];
        _accessoryBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _accessoryBtn;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
