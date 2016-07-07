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
@property (nonatomic,strong) UIButton *editeButton;
@property (nonatomic,strong) UIButton *deleteButton;
@property (nonatomic,strong) UIImageView *backImage;
@property (nonatomic,strong) UIView *bottomlineView;
@property (nonatomic,strong) UIView *toplineView;
@end

@implementation SSJBookKeepingHomeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.isAnimating = NO;
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
    self.toplineView.height = self.height / 2;
    self.toplineView.centerX = self.width / 2;
    self.toplineView.top = 0;
    self.bottomlineView.height = self.height / 2;
    self.bottomlineView.centerX = self.width / 2;
    self.bottomlineView.bottom = self.height;
    if ([self.item.billId isEqualToString:@"-1"]) {
        self.categoryImageButton.size = CGSizeMake(6, 6);
        self.categoryImageButton.layer.cornerRadius = 3.f;
    }else{
        self.categoryImageButton.size = CGSizeMake(38, 38);
        self.categoryImageButton.layer.cornerRadius = 19.f;
    }
    self.categoryImageButton.centerY = self.height * 0.5;
    self.categoryImageButton.centerX = self.width * 0.5;
    self.incomeLabel.rightBottom = CGPointMake(self.categoryImageButton.left - 5, self.height);
    self.incomeLabel.centerY = self.height / 2;
    self.expenditureLabel.leftBottom = CGPointMake(self.categoryImageButton.right + 10, self.height);
    self.expenditureLabel.centerY = self.height / 2;
    self.incomeMemoLabel.width = self.width / 2 - 30;
    self.incomeMemoLabel.rightTop = CGPointMake(self.incomeLabel.right, self.incomeLabel.bottom + 5);
    self.expentureMemoLabel.width = self.width / 2 - 30;
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
        _incomeLabel.font = [UIFont systemFontOfSize:15];
        _incomeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [_incomeLabel sizeToFit];
    }
    return _incomeLabel;
}

-(UILabel*)expenditureLabel{
    if (!_expenditureLabel) {
        _expenditureLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _expenditureLabel.font = [UIFont systemFontOfSize:15];
        _expenditureLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [_expenditureLabel sizeToFit];
    }
    return _expenditureLabel;
}

-(UIButton*)categoryImageButton{
    if (_categoryImageButton == nil) {
        _categoryImageButton = [[UIButton alloc]init];
        [_categoryImageButton ssj_setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _categoryImageButton.backgroundColor = [UIColor whiteColor];
        _categoryImageButton.contentMode = UIViewContentModeScaleAspectFill;
        _categoryImageButton.layer.masksToBounds = YES;
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
        [_deleteButton setImage:[UIImage imageNamed:@"home_delete"] forState:UIControlStateNormal];
        _deleteButton.layer.cornerRadius = 16;
        [_deleteButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

-(UILabel *)incomeMemoLabel{
    if (!_incomeMemoLabel) {
        _incomeMemoLabel = [[UILabel alloc]init];
        _incomeMemoLabel.textAlignment = NSTextAlignmentRight;
        _incomeMemoLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _incomeMemoLabel.font = [UIFont systemFontOfSize:14];
    }
    return _incomeMemoLabel;
}

-(UILabel *)expentureMemoLabel{
    if (!_expentureMemoLabel) {
        _expentureMemoLabel = [[UILabel alloc]init];
        _expentureMemoLabel.textAlignment = NSTextAlignmentLeft;
        _expentureMemoLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _expentureMemoLabel.font = [UIFont systemFontOfSize:14];
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
        [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick:)];
        singleTap.numberOfTapsRequired = 1;
        [_expentureImage addGestureRecognizer:singleTap];
    }
    return _expentureImage;
}

-(UIView *)toplineView{
    if (!_toplineView) {
        _toplineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1 , self.height / 2)];
        _toplineView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor];
    }
    return _toplineView;
}

-(UIView *)bottomlineView{
    if (!_bottomlineView) {
        _bottomlineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1 , self.height / 2)];
        _bottomlineView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor];
    }
    return _bottomlineView;
}

-(void)buttonClicked{
    if (self.beginEditeBtnClickBlock) {
        self.beginEditeBtnClickBlock(self);
    }
}


-(void)setItem:(SSJBillingChargeCellItem *)item{
    _item = item;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *billDate=[dateFormatter dateFromString:item.billDate];
    long day = billDate.day;
    long month = billDate.month;
    long year = billDate.year;
    long currentMonth = [NSDate date].month;
    long currentYear = [NSDate date].year;
    if ([_item.billId isEqualToString:@"-1"]) {
        _IncomeImage.userInteractionEnabled = NO;
        _expentureImage.userInteractionEnabled = NO;
        _categoryImageButton.layer.borderWidth = 0;
        _categoryImageButton.userInteractionEnabled = NO;
        [_categoryImageButton setImage:nil forState:UIControlStateNormal];
        _categoryImageButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_categoryImageButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor] forState:UIControlStateNormal];
        _IncomeImage.hidden = YES;
        _expentureImage.hidden = YES;
        _IncomeImage.image = nil;
        _expentureImage.image = nil;
        _incomeMemoLabel.text = @"";
        _expentureMemoLabel.text = @"";
        if ([_item.money doubleValue] < 0) {
            self.expenditureLabel.hidden = NO;
            self.incomeLabel.hidden = NO;
            self.incomeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
            self.expenditureLabel.text = [NSString stringWithFormat:@"%.2f",[item.money doubleValue]];
            self.expenditureLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
            [self.expenditureLabel sizeToFit];
            if (month == currentMonth) {
                if (day == [NSDate date].day) {
                    self.incomeLabel.text = [NSString stringWithFormat:@"今天"];
                }else if (day == [NSDate date].day - 1){
                    self.incomeLabel.text = [NSString stringWithFormat:@"昨天"];
                }else{
                    self.incomeLabel.text = [NSString stringWithFormat:@"%ld日",day];
                }
            }else if(year == currentYear){
                self.incomeLabel.text = [NSString stringWithFormat:@"%ld月%ld日",month,day];
            }else{
                self.incomeLabel.text = [NSString stringWithFormat:@"%ld年%ld月%ld日",year,month,day];
            }
            [self.incomeLabel sizeToFit];

        }else{
            self.expenditureLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
            self.incomeLabel.text = [NSString stringWithFormat:@"+%.2f",[_item.money doubleValue]];
            self.incomeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
            [self.incomeLabel sizeToFit];
            if (month == currentMonth) {
                if (day == [NSDate date].day) {
                    self.expenditureLabel.text = [NSString stringWithFormat:@"今天"];
                }else if (day == [NSDate date].day - 1){
                    self.expenditureLabel.text = [NSString stringWithFormat:@"昨天"];
                }else{
                    self.expenditureLabel.text = [NSString stringWithFormat:@"%ld日",day];
                }
            }else if(year == currentYear){
                self.expenditureLabel.text = [NSString stringWithFormat:@"%ld月%ld日",month,day];
            }else{
                self.expenditureLabel.text = [NSString stringWithFormat:@"%ld年%ld月%ld日",year,month,day];
            }
            [self.expenditureLabel sizeToFit];
        }
    }else{
        [_categoryImageButton ssj_setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if (!_item.incomeOrExpence) {
            self.incomeLabel.text = [NSString stringWithFormat:@"%@%.2f",_item.typeName,[_item.money doubleValue]];
            [self.incomeLabel sizeToFit];
            self.incomeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
            self.expenditureLabel.text = @"";
            self.incomeMemoLabel.text = _item.chargeMemo;
            [self.incomeMemoLabel sizeToFit];
            self.expentureMemoLabel.text = @"";
        }else{
            self.expenditureLabel.text = [NSString stringWithFormat:@"%@%.2f",_item.typeName,[_item.money doubleValue]];
            self.expenditureLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
            [self.expenditureLabel sizeToFit];
            self.incomeLabel.text = @"";
            self.expentureMemoLabel.text = _item.chargeMemo;
            [self.expentureMemoLabel sizeToFit];
            self.incomeMemoLabel.text = @"";
        }
        UIImage *image = [[UIImage imageWithCGImage:[UIImage imageNamed:_item.imageName].CGImage scale:1.5*[UIScreen mainScreen].scale orientation:UIImageOrientationUp] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _categoryImageButton.tintColor = [UIColor ssj_colorWithHex:_item.colorValue];
        _categoryImageButton.contentMode = UIViewContentModeCenter;
        [_categoryImageButton setImage:image forState:UIControlStateNormal];
        _categoryImageButton.layer.borderColor = [UIColor ssj_colorWithHex:_item.colorValue].CGColor;
        _categoryImageButton.layer.borderWidth = 1;
        _categoryImageButton.backgroundColor = [UIColor clearColor];
        _categoryImageButton.userInteractionEnabled = YES;
        [_categoryImageButton setTitle:@"" forState:UIControlStateNormal];
        if (!(self.item.chargeImage == nil || [self.item.chargeImage isEqualToString:@""])) {
            _IncomeImage.userInteractionEnabled = YES;
            _expentureImage.userInteractionEnabled = YES;
            if ([[NSFileManager defaultManager] fileExistsAtPath:SSJImagePath(self.item.chargeImage)]) {
                if (_item.incomeOrExpence) {
                    _IncomeImage.hidden = YES;
                    _expentureImage.hidden = NO;
                    [self.expentureImage sd_setImageWithURL:[NSURL fileURLWithPath:SSJImagePath(_item.chargeImage)]];
                    self.IncomeImage.image = nil;
                }else{
                    _expentureImage.hidden = YES;

                    _IncomeImage.hidden = NO;
                    [self.IncomeImage sd_setImageWithURL:[NSURL fileURLWithPath:SSJImagePath(_item.chargeImage)]];
                    self.expentureImage.image = nil;
                }
            }else{
                if (self.item.incomeOrExpence) {
                    _IncomeImage.hidden = YES;
                    _expentureImage.hidden = NO;
                    [self.expentureImage sd_setImageWithURL:[NSURL URLWithString:SSJGetChargeImageUrl(_item.chargeThumbImage)]];
                    self.IncomeImage.image = nil;
                }else{
                    _expentureImage.hidden = YES;
                    _IncomeImage.hidden = NO;
                    [self.IncomeImage sd_setImageWithURL:[NSURL URLWithString:SSJGetChargeImageUrl(_item.chargeThumbImage)]];
                    self.expentureImage.image = nil;
                }
            }
        }else{
            _IncomeImage.userInteractionEnabled = NO;
            _expentureImage.userInteractionEnabled = NO;
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
        NSString *userId = SSJUSERID();
        NSString *booksId = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userId];
        [db executeUpdate:@"UPDATE BK_USER_CHARGE SET OPERATORTYPE = 2 , CWRITEDATE = ? , IVERSION = ? WHERE ICHARGEID = ?",[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),weakSelf.item.ID];
        if ([db intForQuery:@"SELECT ITYPE FROM BK_BILL_TYPE WHERE ID = ?",weakSelf.item.billId]) {
            if (![db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE + ? WHERE  CFUNDID = ?",[NSNumber numberWithDouble:[self.item.money doubleValue]],weakSelf.item.fundId] || ![db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET EXPENCEAMOUNT = EXPENCEAMOUNT - ? , SUMAMOUNT = SUMAMOUNT + ? , CWRITEDATE = ? WHERE CBILLDATE = ? and cbooksid = ?",[NSNumber numberWithDouble:[weakSelf.item.money doubleValue]],[NSNumber numberWithDouble:[weakSelf.item.money doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],weakSelf.item.billDate,booksId])
            {
                *rollback = YES;
            };
        }else{
            if (![db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE - ? WHERE  CFUNDID = ?",[NSNumber numberWithDouble:[weakSelf.item.money doubleValue]],weakSelf.item.fundId] || ![db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET INCOMEAMOUNT = INCOMEAMOUNT - ? , SUMAMOUnT = SUMAMOUNT - ? , CWRITEDATE = ? WHERE CBILLDATE = ? and cbooksid = ?",[NSNumber numberWithDouble:[weakSelf.item.money doubleValue]],[NSNumber numberWithDouble:[weakSelf.item.money doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],weakSelf.item.billDate,booksId])
            {
                *rollback = YES;
            };
        }
        [db executeUpdate:@"DELETE FROM BK_DAILYSUM_CHARGE WHERE SUMAMOUNT = 0 AND INCOMEAMOUNT = 0 AND EXPENCEAMOUNT = 0"];
    }];
    
    [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
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

-(void)shake{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    anim.keyPath = @"transform.translation.y";
    
    anim.values = @[@(-1),  @(1), @(-1)];
    
    anim.duration = 0.25;
    // 动画的重复执行次数
    anim.repeatCount = 2;
    
    // 保持动画执行完毕后的状态
    anim.removedOnCompletion = NO;
    
    anim.fillMode = kCAFillModeForwards;
    
    [self.categoryImageButton.layer addAnimation:anim forKey:@"shake"];
}

-(void)animatedShowCellWithDistance:(float)distance delay:(float)delay completion:(void (^ __nullable)())completion{
    if (!self.isAnimating) {
        self.incomeLabel.alpha = 0;
        self.expenditureLabel.alpha = 0;
        self.incomeMemoLabel.alpha = 0;
        self.expentureMemoLabel.alpha = 0;
        self.IncomeImage.alpha = 0;
        self.expentureImage.alpha = 0;
        //    self.bookKeepingHeader.expenditureTitleLabel.alpha = 0;
        //    self.bookKeepingHeader.incomeTitleLabel.alpha = 0;
        self.categoryImageButton.transform = CGAffineTransformMakeTranslation(0, distance);
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.7 delay:delay options:UIViewAnimationOptionTransitionNone animations:^{
            weakSelf.categoryImageButton.transform = CGAffineTransformIdentity;
            weakSelf.isAnimating = YES;
        } completion:^(BOOL finished) {
            [weakSelf shake];
            [UIView animateWithDuration:0.4 animations:^{
                weakSelf.isAnimating = YES;
                weakSelf.incomeLabel.alpha = 1;
                weakSelf.expenditureLabel.alpha = 1;
                weakSelf.incomeMemoLabel.alpha = 1;
                weakSelf.expentureMemoLabel.alpha = 1;
                weakSelf.IncomeImage.alpha = 1;
                weakSelf.expentureImage.alpha = 1;
                //            weakSelf.bookKeepingHeader.expenditureTitleLabel.alpha = 1;
                //            weakSelf.bookKeepingHeader.incomeTitleLabel.alpha = 1;
            } completion:^(BOOL finished) {
                if (completion) {
                    completion();
                }
            }];
        }];
    }

}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    self.incomeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.expenditureLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.incomeMemoLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.expentureMemoLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.toplineView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor];
    self.bottomlineView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor];
}

@end
