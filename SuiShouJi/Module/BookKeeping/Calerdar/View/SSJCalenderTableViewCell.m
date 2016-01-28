//
//  SSJCalenderTableViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCalenderTableViewCell.h"
#import "SSJDatabaseQueue.h"
#import "FMDB.h"

@interface SSJCalenderTableViewCell ()

@property (nonatomic, strong) UILabel *moneyLab;
@property (nonatomic, strong) NSString *cellImage;
@property (nonatomic,strong) NSString *cellTitle;
@property (nonatomic,strong) NSString *cellColor;
@property (nonatomic)BOOL incomeOrExpence;
@end

@implementation SSJCalenderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.textLabel.font = [UIFont systemFontOfSize:15];
        self.textLabel.textColor = [UIColor ssj_colorWithHex:@"#a7a7a7"];
        
        self.imageView.contentMode = UIViewContentModeCenter;
        self.imageView.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
        
        [self.contentView addSubview:self.moneyLab];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageDiam = 26;
    
    self.imageView.left = 10;
    self.imageView.size = CGSizeMake(imageDiam, imageDiam);
    self.imageView.leftTop = CGPointMake(10, (self.contentView.height - imageDiam) * 0.5);
    self.imageView.layer.cornerRadius = imageDiam * 0.5;
    self.imageView.contentScaleFactor = [UIScreen mainScreen].scale * self.imageView.image.size.width / (imageDiam * 0.75);
    
    self.textLabel.left = self.imageView.right + 10;
    
    self.moneyLab.right = self.contentView.width - 10;
    self.moneyLab.centerY = self.contentView.height * 0.5;
}

- (void)setCellItem:(SSJBaseItem *)cellItem {
    [super setCellItem:cellItem];
    if (![cellItem isKindOfClass:[SSJBookKeepHomeItem class]]) {
        return;
    }
    
    SSJBookKeepHomeItem *item = (SSJBookKeepHomeItem *)cellItem;
    [self getBillDetailWithBillId:item.billID];
    self.imageView.image = [UIImage imageNamed:self.cellImage];
    self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:self.cellColor].CGColor;
    self.textLabel.text = self.cellTitle;
    [self.textLabel sizeToFit];
    self.moneyLab.text = [NSString stringWithFormat:@"%@%.2f", self.incomeOrExpence ? @"－" : @"＋", item.chargeMoney];
    [self.moneyLab sizeToFit];
    
    [self setNeedsLayout];
}

- (UILabel *)moneyLab {
    if (!_moneyLab) {
        _moneyLab = [[UILabel alloc] init];
        _moneyLab.backgroundColor = [UIColor whiteColor];
        _moneyLab.font = [UIFont systemFontOfSize:20];
    }
    return _moneyLab;
}

-(void)getBillDetailWithBillId:(NSString *)billId{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM BK_BILL_TYPE WHERE ID = ? ",billId];
        while ([rs next]) {
            weakSelf.cellTitle = [rs stringForColumn:@"CNAME"];
            weakSelf.cellImage = [rs stringForColumn:@"CCOIN"];
            weakSelf.cellColor = [rs stringForColumn:@"CCOLOR"];
            weakSelf.incomeOrExpence = [rs boolForColumn:@"ITYPE"];
        }
    }];
}

@end
