//
//  SSJBookKeepingHomeTableViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/15.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomeTableViewCell.h"
#import "FMDB.h"

@interface SSJBookKeepingHomeTableViewCell()
@property (nonatomic,strong) UIButton *categoryImageButton;
@property (nonatomic,strong) UILabel *incomeLabel;
@property (nonatomic,strong) UILabel *expenditureLabel;
@end

@implementation SSJBookKeepingHomeTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.categoryImageButton];
        [self addSubview:self.expenditureLabel];
        [self addSubview:self.incomeLabel];
    }
    return self;
}

-(void)layoutSubviews{
    self.categoryImageButton.bottom = self.height;
    self.categoryImageButton.centerX = self.centerX;
    self.expenditureLabel.rightBottom = CGPointMake(self.categoryImageButton.left - 5, self.height);
    self.expenditureLabel.centerY = self.categoryImageButton.centerY;
    self.incomeLabel.leftBottom = CGPointMake(self.categoryImageButton.right + 10, self.height);
    self.incomeLabel.centerY = self.categoryImageButton.centerY;
    
}

-(UILabel*)incomeLabel{
    if (!_incomeLabel) {
        _incomeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _incomeLabel.font = [UIFont systemFontOfSize:13];
        _incomeLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        [_incomeLabel sizeToFit];
    }
    return _incomeLabel;
}

-(UILabel*)expenditureLabel{
    if (!_expenditureLabel) {
        _expenditureLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _expenditureLabel.font = [UIFont systemFontOfSize:13];
        _expenditureLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        [_expenditureLabel sizeToFit];
    }
    return _expenditureLabel;
}

-(UIButton*)categoryImageButton{
    if (_categoryImageButton == nil) {
        _categoryImageButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        _categoryImageButton.layer.cornerRadius = 15;
        [_categoryImageButton addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _categoryImageButton;
}

-(void)buttonClicked{
    NSLog(@"编辑");
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(ctx, self.centerX, 0);
    CGContextAddLineToPoint(ctx, self.centerX, self.categoryImageButton.top);
    CGContextSetRGBStrokeColor(ctx, 204.0/225, 204.0/255, 204.0/255, 1.0);
    CGContextSetLineWidth(ctx, 1 / [UIScreen mainScreen].scale);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextStrokePath(ctx);
}

-(void)setItem:(SSJBookKeepHomeItem *)item{
    _item = item;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *billDate=[dateFormatter dateFromString:_item.billDate];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:billDate];
    long day = [dateComponent day];
    if ([_item.billID isEqualToString:@"-1"]) {
        [self.categoryImageButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        if (_item.chargeMoney < 0) {
            self.incomeLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
            self.expenditureLabel.text = [NSString stringWithFormat:@"%f",_item.chargeMoney];
            [self.expenditureLabel sizeToFit];
            self.incomeLabel.text = [NSString stringWithFormat:@"%ld日",day];
            [self.incomeLabel sizeToFit];

        }else{
            self.expenditureLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
            self.incomeLabel.text = [NSString stringWithFormat:@"%f",_item.chargeMoney];
            [self.incomeLabel sizeToFit];
            self.expenditureLabel.text = [NSString stringWithFormat:@"%ld日",day];
            [self.expenditureLabel sizeToFit];
        }
    }else{
        NSString *iconName;
        NSString *categoryName;
        int categoryType = 0;
        FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
        if (![db open]) {
            NSLog(@"Could not open db");
            return ;
        }
        FMResultSet *rs = [db executeQuery:@"SELECT CCOIN, CNAME , ITYPE FROM BK_BILL_TYPE WHERE ID = ?",item.billID];
        while ([rs next]) {
            iconName = [rs stringForColumn:@"CCOIN"];
            categoryName = [rs stringForColumn:@"CNAME"];
            categoryType = [rs intForColumn:@"ITYPE"];
        }
        if (categoryType) {
            self.expenditureLabel.text = [NSString stringWithFormat:@"%@%f",categoryName,_item.chargeMoney];
            [self.expenditureLabel sizeToFit];
        }else{
            self.incomeLabel.text = [NSString stringWithFormat:@"%@%f",categoryName,_item.chargeMoney];
            [self.incomeLabel sizeToFit];

        }
        [_categoryImageButton setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
        [db close];
    }
}
@end
