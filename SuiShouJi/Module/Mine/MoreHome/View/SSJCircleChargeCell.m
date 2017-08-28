//
//  SSJCircleChargeCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCircleChargeCell.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"

@interface SSJCircleChargeCell()

@property (nonatomic,strong) UIImageView *categoryImage;

@property (nonatomic,strong) UILabel *categoryLabel;

@property (nonatomic,strong) UIImageView *circleImage;

@property (nonatomic,strong) UILabel *moneyLabel;

@property (nonatomic,strong) UILabel *circleLabel;

@property (nonatomic,strong) UILabel *timeLabel;

@property (nonatomic,strong) UILabel *booksLabel;

@property (nonatomic,strong) UISwitch *switchButton;

@property (nonatomic,strong) UIView *seperatorView;

@end
@implementation SSJCircleChargeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.categoryImage];
        [self.contentView addSubview:self.seperatorView];
        [self.contentView addSubview:self.categoryLabel];
        [self.contentView addSubview:self.moneyLabel];
        [self.contentView addSubview:self.circleImage];
        [self.contentView addSubview:self.circleLabel];
        [self.contentView addSubview:self.switchButton];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.booksLabel];
    }
    return self;
}

- (void)updateConstraints {
    [self.categoryImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(self.categoryLabel);
    }];
    
    [self.categoryLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_centerY).offset(-6);
        make.left.mas_equalTo(44);
    }];
    
    [self.moneyLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.categoryLabel.mas_right).offset(10);
        make.centerY.mas_equalTo(self.categoryLabel);
    }];
    
    [self.circleImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.categoryLabel);
        make.top.mas_equalTo(self.mas_centerY).offset(6);
    }];
    
    [self.circleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.circleImage.mas_right).offset(10);
        make.centerY.mas_equalTo(self.circleImage);
    }];
    
    [self.seperatorView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(1, 9));
        make.left.mas_equalTo(self.circleLabel.mas_right).offset(10);
        make.centerY.mas_equalTo(self.circleImage);
    }];
    
    [self.booksLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.seperatorView.mas_right).offset(10);
        make.centerY.mas_equalTo(self.circleImage);
    }];
    
    [self.switchButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.categoryLabel);
        make.right.mas_equalTo(self.mas_right).offset(-15);
    }];
    
    [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.circleImage);
        make.right.mas_equalTo(self.mas_right).offset(-15);
    }];

    
    [super updateConstraints];
}

-(UIImageView *)categoryImage{
    if (!_categoryImage) {
        _categoryImage = [[UIImageView alloc]init];
        _categoryImage.layer.borderWidth = 1.f;
        _categoryImage.layer.cornerRadius = 10.f;
        _categoryImage.contentMode = UIViewContentModeCenter;
    }
    return _categoryImage;
}

-(UIImageView *)circleImage{
    if (!_circleImage) {
        _circleImage = [[UIImageView alloc]init];
        _circleImage.image = [[UIImage imageNamed:@"zhouqi"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _circleImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _circleImage;
}

-(UILabel *)categoryLabel{
    if (!_categoryLabel) {
        _categoryLabel = [[UILabel alloc]init];
        _categoryLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _categoryLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _categoryLabel;
}

-(UILabel *)moneyLabel{
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc]init];
        _moneyLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _moneyLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];

    }
    return _moneyLabel;
}

-(UILabel *)circleLabel{
    if (!_circleLabel) {
        _circleLabel = [[UILabel alloc]init];
        _circleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _circleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        
    }
    return _circleLabel;
}

-(UISwitch *)switchButton{
    if (!_switchButton) {
        _switchButton = [[UISwitch alloc] init];
        _switchButton.onTintColor = [UIColor ssj_colorWithHex:@"43cf78"];
        [_switchButton addTarget:self action:@selector(switchButtonClicked:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchButton;
}

-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _timeLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _timeLabel;
}

- (UIView *)seperatorView {
    if (!_seperatorView) {
        _seperatorView = [[UIView alloc] init];
        _seperatorView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _seperatorView;
}

- (UILabel *)booksLabel {
    if (!_booksLabel) {
        _booksLabel = [[UILabel alloc] init];
        _booksLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _booksLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _booksLabel;
}

-(void)setItem:(SSJBillingChargeCellItem *)item{
    _item = item;
    self.switchButton.on = _item.isOnOrNot;
    self.categoryImage.image = [[[UIImage imageNamed:_item.imageName] ssj_compressWithinSize:CGSizeMake(15, 15)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.categoryImage.layer.borderColor = [UIColor ssj_colorWithHex:_item.colorValue].CGColor;
    self.categoryImage.tintColor = [UIColor ssj_colorWithHex:_item.colorValue];
    self.categoryLabel.text = _item.typeName;
    self.booksLabel.text = _item.booksName;
    if (_item.incomeOrExpence) {
        self.moneyLabel.text = [NSString stringWithFormat:@"-%.2f",[_item.money doubleValue]];
    }else{
        self.moneyLabel.text = [NSString stringWithFormat:@"+%.2f",[_item.money doubleValue]];
    }
    self.timeLabel.text = _item.billDate;
    switch (_item.chargeCircleType) {
        case SSJCyclePeriodTypeDaily:
            self.circleLabel.text = @"每天";
            break;
        case SSJCyclePeriodTypeWorkday:
            self.circleLabel.text = @"每个工作日";
            break;
        case SSJCyclePeriodTypePerWeekend:
            self.circleLabel.text = @"每个周末";
            break;
        case SSJCyclePeriodTypeWeekly:
            self.circleLabel.text = @"每周";
            break;
        case SSJCyclePeriodTypePerMonth:
            self.circleLabel.text = @"每月";
            break;
        case SSJCyclePeriodTypeLastDayPerMonth:
            self.circleLabel.text = @"每月最后一天";
            break;
        case SSJCyclePeriodTypePerYear:
            self.circleLabel.text = @"每年";
            break;
        default:
            break;
    }
    [self updateConstraintsIfNeeded];
}


-(void)switchButtonClicked:(id)sender{
    [self closeChargeConfig];
}

-(void)closeChargeConfig{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db){
        BOOL success = YES;
        if (weakSelf.switchButton.isOn) {
            if ([db intForQuery:@"select operatortype from bk_fund_info where cfundid = ?",weakSelf.item.fundId] == 2) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakSelf.openSpecialCircle) {
                        weakSelf.openSpecialCircle(weakSelf.item);
                    }
                    return;
                });
            }else{
                success = [db executeUpdate:@"update BK_CHARGE_PERIOD_CONFIG set ISTATE = 1 , CWRITEDATE = ? , CBILLDATE = ? , IVERSION = ? where ICONFIGID = ?",[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"],@(SSJSyncVersion()),weakSelf.item.sundryId];
            }
        }else{
            success = [db executeUpdate:@"update BK_CHARGE_PERIOD_CONFIG set ISTATE = 0 , CWRITEDATE = ? , IVERSION = ? where ICONFIGID = ?",[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),weakSelf.item.sundryId];
        }
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    }];
    
    [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
}

- (void)updateCellAppearanceAfterThemeChanged {
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
