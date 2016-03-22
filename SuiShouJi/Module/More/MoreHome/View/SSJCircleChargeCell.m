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
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.categoryImage.size = CGSizeMake(46, 46);
    self.categoryImage.left = 10;
    self.categoryImage.centerY = self.height / 2;
    self.categoryLabel.left = self.categoryImage.right + 10;
    self.categoryLabel.top= 13;
    self.moneyLabel.left = self.categoryLabel.right + 10;
    self.moneyLabel.centerY = self.categoryLabel.centerY;
    self.circleImage.size = CGSizeMake(20, 20);
    self.circleImage.left = self.categoryLabel.left;
    self.circleImage.top = self.categoryLabel.bottom + 15;
    self.circleLabel.centerY = self.circleImage.centerY;
    self.circleLabel.left = self.circleImage.right + 10;
    self.switchButton.right = self.width - 10;
    self.switchButton.centerY = self.height / 2;
}

-(UIImageView *)categoryImage{
    if (!_categoryImage) {
        _categoryImage = [[UIImageView alloc]init];
        _categoryImage.tintColor = [UIColor whiteColor];
        _categoryImage.layer.cornerRadius = 23;
        _categoryImage.contentMode = UIViewContentModeCenter;
    }
    return _categoryImage;
}

-(UIImageView *)circleImage{
    if (!_circleImage) {
        _circleImage = [[UIImageView alloc]init];
        _circleImage.image = [UIImage imageNamed:@"xuhuan_sel"];
        
    }
    return _circleImage;
}

-(UILabel *)categoryLabel{
    if (!_categoryLabel) {
        _categoryLabel = [[UILabel alloc]init];
        _categoryLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _categoryLabel.font = [UIFont systemFontOfSize:18];
    }
    return _categoryLabel;
}

-(UILabel *)moneyLabel{
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc]init];
        _moneyLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _moneyLabel.font = [UIFont systemFontOfSize:18];

    }
    return _moneyLabel;
}

-(UILabel *)circleLabel{
    if (!_circleLabel) {
        _circleLabel = [[UILabel alloc]init];
        _circleLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _circleLabel.font = [UIFont systemFontOfSize:15];
        
    }
    return _circleLabel;
}

-(UISwitch *)switchButton{
    if (!_switchButton) {
        _switchButton = [[UISwitch alloc]init];
        _switchButton.onTintColor = [UIColor ssj_colorWithHex:@"43cf78"];
        [_switchButton addTarget:self action:@selector(switchButtonClicked:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchButton;
}

-(void)setItem:(SSJBillingChargeCellItem *)item{
    _item = item;
    self.switchButton.on = _item.isOnOrNot;
    self.categoryImage.image = [[UIImage imageNamed:_item.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.categoryImage.backgroundColor = [UIColor ssj_colorWithHex:_item.colorValue];
    self.categoryLabel.text = _item.typeName;
    [self.categoryLabel sizeToFit];
    if (_item.incomeOrExpence) {
        self.moneyLabel.text = [NSString stringWithFormat:@"-%.2f",[_item.money doubleValue]];
    }else{
        self.moneyLabel.text = [NSString stringWithFormat:@"+%.2f",[_item.money doubleValue]];
    }
    [self.moneyLabel sizeToFit];
    self.timeLabel.text = _item.billDate;
    [self.timeLabel sizeToFit];
    switch (_item.chargeCircleType) {
        case 0:
            self.circleLabel.text = @"每天";
            break;
        case 1:
            self.circleLabel.text = @"每个工作日";
            break;
        case 2:
            self.circleLabel.text = @"每个周末";
            break;
        case 3:
            self.circleLabel.text = @"每周";
            break;
        case 4:
            self.circleLabel.text = @"每月";
            break;
        case 5:
            self.circleLabel.text = @"每年";
            break;
        case 6:
            self.circleLabel.text = @"每月最后一天";
            break;
        default:
            break;
    }
    [self.circleLabel sizeToFit];
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
                success = [db executeUpdate:@"update BK_CHARGE_PERIOD_CONFIG set ISTATE = 1 , CWRITEDATE = ? , CBILLDATE = ? , IVERSION = ? where ICONFIGID = ?",[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"],@(SSJSyncVersion()),weakSelf.item.configId];
            }
        }else{
            success = [db executeUpdate:@"update BK_CHARGE_PERIOD_CONFIG set ISTATE = 0 , CWRITEDATE = ? , IVERSION = ? where ICONFIGID = ?",[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),weakSelf.item.configId];
        }
        if (success && SSJSyncSetting() == SSJSyncSettingTypeWIFI) {
            [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:NULL failure:NULL];
        }
    }];
    if (SSJSyncSetting() == SSJSyncSettingTypeWIFI) {
        [[SSJDataSynchronizer shareInstance]startSyncWithSuccess:^(){
            
        }failure:^(NSError *error) {
            
        }];
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
