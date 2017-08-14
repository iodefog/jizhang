//
//  SSJNewMineHomeTabelviewCell.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJNewMineHomeTabelviewCell.h"

@interface SSJNewMineHomeTabelviewCell()

@property (nonatomic,strong) UILabel *titleLab;

@property(nonatomic, strong) UIImageView *cellImageView;

@property(nonatomic) UIImage *cellImage;

@property (nonatomic, strong) UIView *dotView;


@end

@implementation SSJNewMineHomeTabelviewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.cellImageView];
        
        [self.contentView addSubview:self.titleLab];
        
        [self.contentView addSubview:self.dotView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)updateConstraints {
    
    [self.cellImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        if ([self.item.image hasPrefix:@"http"]) {
            make.size.mas_equalTo(CGSizeMake(self.cellImage.size.width / 2, self.cellImage.size.height / 2));
        }
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(44);
        make.centerY.mas_equalTo(self.cellImageView);
    }];
    
    [self.dotView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.cellImageView.mas_right);
        make.size.mas_equalTo(CGSizeMake(5, 5));
        make.centerY.mas_equalTo(self.cellImageView.mas_top);
    }];
    
    [super updateConstraints];
}

-(UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc]init];
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _titleLab;
}

-(UIImageView *)cellImageView{
    if (!_cellImageView) {
        _cellImageView = [[UIImageView alloc]init];
    }
    return _cellImageView;
}

- (UIView *)dotView
{
    if (!_dotView) {
        _dotView = [[UIView alloc] init];
//        _dotView.size = CGSizeMake(5, 5);
        _dotView.layer.cornerRadius = 2.5;
        _dotView.hidden = YES;
        [_dotView clipsToBounds];
    }
    return _dotView;
}


- (void)setItem:(SSJMineHomeTableViewItem *)item {
    
    _item = item;
    
    self.titleLab.text = item.title;
    
    if ([item.image hasPrefix:@"http"]) {

        @weakify(self);
        [self.cellImageView sd_setImageWithURL:[NSURL URLWithString:_item.image] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            @strongify(self);
            self.cellImage = image;
            [self setNeedsUpdateConstraints];
        }];

    } else {
        self.cellImageView.image = [UIImage imageNamed:item.image];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SSJLoveKey] == NO && [item.title isEqualToString:@"爱的鼓励"]) {
        self.dotView.hidden = NO;
    } else {
        self.dotView.hidden = YES;
    }
    
    [self setNeedsUpdateConstraints];
}

- (void)updateCellAppearanceAfterThemeChanged{
    [super updateCellAppearanceAfterThemeChanged];
    self.titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.dotView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
}


@end
