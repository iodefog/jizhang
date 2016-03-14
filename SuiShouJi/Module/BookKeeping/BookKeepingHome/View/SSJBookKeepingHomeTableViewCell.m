//
//  SSJBookKeepingHomeTableViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/15.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomeTableViewCell.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "FMDB.h"

@interface SSJBookKeepingHomeTableViewCell()
@property (nonatomic,strong) UIButton *categoryImageButton;
@property (nonatomic,strong) UIButton *editeButton;
@property (nonatomic,strong) UIButton *deleteButton;
@property (nonatomic,strong) UILabel *incomeLabel;
@property (nonatomic,strong) UILabel *expenditureLabel;
@property (nonatomic,strong) UIView *toplineView;
@property (nonatomic,strong) UILabel *incomeMemoLabel;
@property (nonatomic,strong) UILabel *expentureMemoLabel;
@property (nonatomic,strong) UIImageView *IncomeImage;
@property (nonatomic,strong) UIImageView *expentureImage;

@end

@implementation SSJBookKeepingHomeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.toplineView];
        [self addSubview:self.bottomlineView];
        [self addSubview:self.categoryImageButton];
        [self addSubview:self.expenditureLabel];
        [self addSubview:self.incomeLabel];
        [self addSubview:self.editeButton];
        [self addSubview:self.deleteButton];
        [self addSubview:self.incomeMemoLabel];
        [self addSubview:self.IncomeImage];
        [self addSubview:self.expentureMemoLabel];
        [self addSubview:self.expentureImage];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.categoryImageButton.centerY = self.height * 0.5;
    self.categoryImageButton.centerX = self.width * 0.5;
    self.incomeLabel.rightBottom = CGPointMake(self.categoryImageButton.left - 5, self.height);
    self.incomeLabel.centerY = self.height / 2;
    self.expenditureLabel.leftBottom = CGPointMake(self.categoryImageButton.right + 10, self.height);
    self.expenditureLabel.centerY = self.height / 2;
    self.toplineView.size = CGSizeMake(1, self.height - self.categoryImageButton.bottom);
    self.toplineView.centerX = self.centerX;
    self.bottomlineView.top = self.categoryImageButton.bottom;
    self.bottomlineView.size = CGSizeMake(1, self.height - self.categoryImageButton.bottom);
    self.bottomlineView.centerX = self.centerX;
    self.incomeMemoLabel.rightTop = CGPointMake(self.incomeLabel.right, self.incomeLabel.bottom + 5);
    self.expentureMemoLabel.leftTop = CGPointMake(self.expenditureLabel.left, self.expenditureLabel.bottom + 5);
    self.IncomeImage.size =CGSizeMake(35, 35);
    self.IncomeImage.left = self.categoryImageButton.right + 10;
    self.IncomeImage.centerY = self.height / 2;
    self.expentureImage.size =CGSizeMake(35, 35);
    self.expentureImage.right = self.categoryImageButton.left - 10;
    self.expentureImage.centerY = self.height / 2;
    if (_isEdite == YES) {
        self.editeButton.frame = self.categoryImageButton.frame;
        self.deleteButton.frame = self.categoryImageButton.frame;
        self.editeButton.hidden = NO;
        self.deleteButton.hidden = NO;
        self.incomeLabel.hidden = YES;
        self.incomeMemoLabel.hidden = YES;
        self.expenditureLabel.hidden = YES;
        self.expentureMemoLabel.hidden = YES;
        self.IncomeImage.hidden = YES;
        self.expentureImage.hidden = YES;
        [UIView animateWithDuration:0.2 animations:^{
            self.deleteButton.centerX = 40;
            self.editeButton.centerX = self.width - 40;
        }completion:nil];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.deleteButton.centerX = self.width / 2;
            self.editeButton.centerX = self.width / 2;
        }completion:^(BOOL success){
            self.editeButton.hidden = YES;
            self.deleteButton.hidden = YES;
            self.expenditureLabel.hidden = NO;
            self.incomeLabel.hidden = NO;
            self.expentureMemoLabel.hidden = NO;
            self.incomeMemoLabel.hidden = NO;
            self.IncomeImage.hidden = NO;
            self.expentureImage.hidden = NO;
        }];
    }

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
        _categoryImageButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 38, 38)];
        _categoryImageButton.backgroundColor = [UIColor whiteColor];
        _categoryImageButton.contentMode = UIViewContentModeScaleAspectFill;
        _categoryImageButton.layer.cornerRadius = 19;
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
        [_deleteButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

-(UIView *)toplineView{
    if (!_toplineView) {
        _toplineView = [[UIView alloc]init];
        _toplineView.backgroundColor = [UIColor ssj_colorWithHex:@"cccccc"];
    }
    return _toplineView;
}

-(UIView *)bottomlineView{
    if (!_bottomlineView) {
        _bottomlineView = [[UIView alloc]init];
        _bottomlineView.backgroundColor = [UIColor ssj_colorWithHex:@"cccccc"];
    }
    return _bottomlineView;
}

-(UILabel *)incomeMemoLabel{
    if (!_incomeMemoLabel) {
        _incomeMemoLabel = [[UILabel alloc]init];
        _incomeMemoLabel.textAlignment = NSTextAlignmentLeft;
        _incomeMemoLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        _incomeMemoLabel.font = [UIFont systemFontOfSize:12];
    }
    return _incomeMemoLabel;
}

-(UILabel *)expentureMemoLabel{
    if (!_expentureMemoLabel) {
        _expentureMemoLabel = [[UILabel alloc]init];
        _expentureMemoLabel.textAlignment = NSTextAlignmentLeft;

        _expentureMemoLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        _expentureMemoLabel.font = [UIFont systemFontOfSize:12];
    }
    return _expentureMemoLabel;
}

-(UIImageView *)IncomeImage{
    if (!_IncomeImage) {
        _IncomeImage = [[UIImageView alloc]init];
        _IncomeImage.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap =
        [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick:)];
         singleTap.numberOfTapsRequired = 1;
         [_IncomeImage addGestureRecognizer:singleTap];
    }
    return _IncomeImage;
}

-(UIImageView *)expentureImage{
    if (!_expentureImage) {
        _expentureImage = [[UIImageView alloc]init];
        _expentureImage.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap =
        [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick: )];
        singleTap.numberOfTapsRequired = 1;
        [_expentureImage addGestureRecognizer:singleTap];
    }
    return _expentureImage;
}

-(void)buttonClicked{
    if (self.beginEditeBtnClickBlock) {
        self.beginEditeBtnClickBlock(self);
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(ctx, self.centerX, 0);
    CGContextAddLineToPoint(ctx, self.centerX, self.categoryImageButton.top);
    CGContextSetRGBStrokeColor(ctx, 204.0/225, 204.0/255, 204.0/255, 1.0);
    CGContextSetLineWidth(ctx, 1);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextStrokePath(ctx);
    [self setNeedsDisplay];
}

-(void)setItem:(SSJBillingChargeCellItem *)item{
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
    if ([item.billId isEqualToString:@"-1"]) {
        _categoryImageButton.layer.borderWidth = 0;
        _categoryImageButton.userInteractionEnabled = NO;
        [_categoryImageButton setImage:nil forState:UIControlStateNormal];
        [_categoryImageButton setTitle:@"结余" forState:UIControlStateNormal];
        _categoryImageButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_categoryImageButton setTintColor:[UIColor whiteColor]];
        _categoryImageButton.backgroundColor = [UIColor ssj_colorWithHex:@"47cfbe"];
        _IncomeImage.image = nil;
        _expentureImage.image = nil;
        _incomeMemoLabel.text = @"";
        _expentureMemoLabel.text = @"";
        if ([item.money doubleValue] < 0) {
            self.expenditureLabel.hidden = NO;
            self.incomeLabel.hidden = NO;
            self.incomeLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
            self.expenditureLabel.text = [NSString stringWithFormat:@"%.2f",[item.money doubleValue]];
            self.expenditureLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
            [self.expenditureLabel sizeToFit];
            if (month == currentMonth) {
                self.incomeLabel.text = [NSString stringWithFormat:@"%ld日",day];
            }else{
                self.incomeLabel.text = [NSString stringWithFormat:@"%ld月%ld日",month,day];
            }
            [self.incomeLabel sizeToFit];

        }else{
            self.expenditureLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
            self.incomeLabel.text = [NSString stringWithFormat:@"+%.2f",[item.money doubleValue]];
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
        if (!item.incomeOrExpence) {
            self.incomeLabel.text = [NSString stringWithFormat:@"%@%.2f",item.typeName,[item.money doubleValue]];
            [self.incomeLabel sizeToFit];
            self.incomeLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
            self.expenditureLabel.text = @"";
            self.incomeMemoLabel.text = self.item.chargeMemo;
            [self.incomeMemoLabel sizeToFit];
            self.expentureMemoLabel.text = @"";
        }else{
            self.expenditureLabel.text = [NSString stringWithFormat:@"%@%.2f",item.typeName,[item.money doubleValue]];
            self.expenditureLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
            [self.expenditureLabel sizeToFit];
            self.incomeLabel.text = @"";
            self.expentureMemoLabel.text = self.item.chargeMemo;
            [self.expentureMemoLabel sizeToFit];
            self.incomeMemoLabel.text = @"";
        }
        UIImage *image = [UIImage imageWithCGImage:[UIImage imageNamed:item.imageName].CGImage scale:1.5*[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        _categoryImageButton.contentMode = UIViewContentModeCenter;
        [_categoryImageButton setImage:image forState:UIControlStateNormal];
        _categoryImageButton.layer.borderColor = [UIColor ssj_colorWithHex:item.colorValue].CGColor;
        _categoryImageButton.layer.borderWidth = 1;
        _categoryImageButton.backgroundColor = [UIColor clearColor];
        _categoryImageButton.userInteractionEnabled = YES;
        [_categoryImageButton setTitle:@"" forState:UIControlStateNormal];
        if (!(self.item.chargeImage == nil || [self.item.chargeImage isEqualToString:@""])) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:SSJImagePath(self.item.chargeImage)]) {
                if (self.item.incomeOrExpence) {
                    self.expentureImage.image = [UIImage imageWithContentsOfFile:SSJImagePath(self.item.chargeImage)];
                    self.IncomeImage.image = nil;
                }else{
                    self.IncomeImage.image = [UIImage imageWithContentsOfFile:SSJImagePath(self.item.chargeImage)];
                    self.expentureImage.image = nil;
                }
            }else{
                if (self.item.incomeOrExpence) {
                    [self.expentureImage sd_setImageWithURL:[NSURL URLWithString:SSJGetChargeImageUrl(self.item.chargeThumbImage)]];
                    self.IncomeImage.image = nil;
                }else{
                    [self.IncomeImage sd_setImageWithURL:[NSURL URLWithString:SSJGetChargeImageUrl(self.item.chargeThumbImage)]];
                    self.expentureImage.image = nil;
                }
            }
        }else{
            self.expentureImage.image = nil;
            self.IncomeImage.image = nil;
        }
    [self setNeedsLayout];
    }
    
}

-(void)setIsEdite:(BOOL)isEdite{
    _isEdite = isEdite;
    
}

-(void)editeButtonClicked{
    if (self.editeBtnClickBlock) {
        self.editeBtnClickBlock(self);
    }
}

-(void)deleteButtonClick{
    [self deleteCharge];
    if (self.deleteButtonClickBlock) {
        self.deleteButtonClickBlock();
    }
}

-(void)deleteCharge{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance]asyncInTransaction:^(FMDatabase *db , BOOL *rollback){
        [db executeUpdate:@"UPDATE BK_USER_CHARGE SET OPERATORTYPE = 2 , CWRITEDATE = ? , IVERSION = ? WHERE ICHARGEID = ?",[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),weakSelf.item.ID];
        if ([db intForQuery:@"SELECT ITYPE FROM BK_BILL_TYPE WHERE ID = ?",weakSelf.item.billId]) {
            if (![db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE + ? WHERE  CFUNDID = ?",[NSNumber numberWithDouble:[self.item.money doubleValue]],weakSelf.item.fundId] || ![db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET EXPENCEAMOUNT = EXPENCEAMOUNT - ? , SUMAMOUNT = SUMAMOUNT + ? , CWRITEDATE = ? WHERE CBILLDATE = ?",[NSNumber numberWithDouble:[weakSelf.item.money doubleValue]],[NSNumber numberWithDouble:[weakSelf.item.money doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],weakSelf.item.billDate])
            {
                *rollback = YES;
            };
        }else{
            if (![db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE - ? WHERE  CFUNDID = ?",[NSNumber numberWithDouble:[weakSelf.item.money doubleValue]],weakSelf.item.fundId] || ![db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET INCOMEAMOUNT = INCOMEAMOUNT - ? , SUMAMOUnT = SUMAMOUNT - ? , CWRITEDATE = ? WHERE CBILLDATE = ?",[NSNumber numberWithDouble:[weakSelf.item.money doubleValue]],[NSNumber numberWithDouble:[weakSelf.item.money doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],weakSelf.item.billDate])
            {
                *rollback = YES;
            };
        }
        [db executeUpdate:@"DELETE FROM BK_DAILYSUM_CHARGE WHERE SUMAMOUNT = 0 AND INCOMEAMOUNT = 0 AND EXPENCEAMOUNT = 0"];
    }];
    if (SSJSyncSetting() == SSJSyncSettingTypeWIFI) {
        [[SSJDataSynchronizer shareInstance]startSyncWithSuccess:^(){
            
        }failure:^(NSError *error) {
            
        }];
    }
}

-(void)imageClick:(UITapGestureRecognizer *)sender{
    if (self.imageClickBlock) {
        self.imageClickBlock(self.item);
    }
}

-(void)setIsLastRowOrNot:(BOOL)isLastRowOrNot{
    _isLastRowOrNot = isLastRowOrNot;
    self.bottomlineView.hidden = !_isLastRowOrNot;
}

@end
