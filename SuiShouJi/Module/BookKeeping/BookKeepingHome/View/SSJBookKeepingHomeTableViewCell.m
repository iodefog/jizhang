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
@property (nonatomic,strong) UIButton *editeButton;
@property (nonatomic,strong) UIButton *deleteButton;
@property (nonatomic,strong) UILabel *incomeLabel;
@property (nonatomic,strong) UILabel *expenditureLabel;

@end

@implementation SSJBookKeepingHomeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.categoryImageButton];
        [self addSubview:self.expenditureLabel];
        [self addSubview:self.incomeLabel];
        [self addSubview:self.editeButton];
        [self addSubview:self.deleteButton];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)layoutSubviews{
    self.categoryImageButton.bottom = self.height;
    self.categoryImageButton.centerX = self.centerX;
    self.editeButton.frame = self.categoryImageButton.frame;
    self.deleteButton.frame = self.categoryImageButton.frame;
    self.incomeLabel.rightBottom = CGPointMake(self.categoryImageButton.left - 5, self.height);
    self.incomeLabel.centerY = self.categoryImageButton.centerY;
    self.expenditureLabel.leftBottom = CGPointMake(self.categoryImageButton.right + 10, self.height);
    self.expenditureLabel.centerY = self.categoryImageButton.centerY;
    
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
        _categoryImageButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 32, 32)];
        _categoryImageButton.contentMode = UIViewContentModeScaleAspectFill;
        _categoryImageButton.layer.cornerRadius = 15;
        [_categoryImageButton addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _categoryImageButton;
}

-(UIButton *)editeButton{
    if (!_editeButton) {
        _editeButton = [[UIButton alloc]init];
        _editeButton.hidden = YES;
        [_editeButton setImage:[UIImage imageNamed:@"home_edit"] forState:UIControlStateNormal];
        _editeButton.layer.cornerRadius = 16;
        [_editeButton addTarget:self action:@selector(editeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editeButton;
}

-(UIButton *)deleteButton{
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc]init];
        _deleteButton.hidden = YES;
        [_deleteButton setImage:[UIImage imageNamed:@"home_delet"] forState:UIControlStateNormal];
        _deleteButton.layer.cornerRadius = 16;
    }
    return _deleteButton;
}

-(void)buttonClicked{
    if (self.beginEditeBtnClickBlock) {
        self.beginEditeBtnClickBlock(self);
    }
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
    NSDate *billDate=[dateFormatter dateFromString:item.billDate];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:billDate];
    NSDateComponents *currentdateComponent = [calendar components:unitFlags fromDate:[NSDate date]];
    long day = [dateComponent day];
    long month = [dateComponent month];
    long currentMonth = [currentdateComponent month];
    if ([item.billID isEqualToString:@"-1"]) {
        [self.categoryImageButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        if (item.chargeMoney < 0) {
            self.expenditureLabel.hidden = NO;
            self.incomeLabel.hidden = NO;
            self.incomeLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
            self.expenditureLabel.text = [NSString stringWithFormat:@"%.2f",item.chargeMoney];
            self.expenditureLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
            [self.expenditureLabel sizeToFit];
            _categoryImageButton.userInteractionEnabled = NO;
            [_categoryImageButton setTitle:@"结余" forState:UIControlStateNormal];
            _categoryImageButton.titleLabel.font = [UIFont systemFontOfSize:13];
            [_categoryImageButton setTintColor:[UIColor whiteColor]];
            _categoryImageButton.backgroundColor = [UIColor ssj_colorWithHex:@"47cfbe"];
            if (month == currentMonth) {
                self.incomeLabel.text = [NSString stringWithFormat:@"%ld日",day];
            }else{
                self.incomeLabel.text = [NSString stringWithFormat:@"%ld月%ld日",month,day];
            }
            [self.incomeLabel sizeToFit];

        }else{
            self.expenditureLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
            self.incomeLabel.text = [NSString stringWithFormat:@"%.2f",item.chargeMoney];
            self.incomeLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
            [self.incomeLabel sizeToFit];
            if (month == currentMonth) {
                self.expenditureLabel.text = [NSString stringWithFormat:@"%ld日",day];
            }else{
                self.expenditureLabel.text = [NSString stringWithFormat:@"%ld日",day];
            }
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
        if (!categoryType) {
            self.incomeLabel.text = [NSString stringWithFormat:@"%@%.2f",categoryName,item.chargeMoney];
            [self.incomeLabel sizeToFit];
            self.incomeLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
            self.expenditureLabel.hidden = YES;
        }else{
            self.expenditureLabel.text = [NSString stringWithFormat:@"%@%.2f",categoryName,item.chargeMoney];
            self.expenditureLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
            [self.expenditureLabel sizeToFit];
            self.incomeLabel.hidden = YES;
        }
        
        [_categoryImageButton setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
        _categoryImageButton.backgroundColor = [UIColor clearColor];
        _categoryImageButton.userInteractionEnabled = YES;
    }
}

-(void)setIsEdite:(BOOL)isEdite{
    _isEdite = isEdite;
    if (_isEdite == YES) {
        self.editeButton.hidden = NO;
        self.deleteButton.hidden = NO;

        [UIView animateKeyframesWithDuration:0.1 delay:0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
            self.editeButton.center = CGPointMake(40, self.height - 15);
            self.deleteButton.center = CGPointMake(self.width - 40, self.height - 15);
        }completion:nil];
    }else{
    
    }
}

-(void)editeButtonClicked{
    if (self.editeBtnClickBlock) {
        self.editeBtnClickBlock(self);
    }
}

@end
