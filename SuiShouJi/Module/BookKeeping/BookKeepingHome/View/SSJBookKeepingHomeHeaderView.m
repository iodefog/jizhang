//
//  SSJBookKeepingHomeHeaderView.m
//  SuiShouJi
//
//  Created by ricky on 16/10/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomeHeaderView.h"

@interface SSJBookKeepingHomeHeaderView()

@property (nonatomic,strong) UIView *bottomlineView;

@property (nonatomic,strong) UIView *toplineView;

@end

@implementation SSJBookKeepingHomeHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.toplineView];
        [self.contentView addSubview:self.bottomlineView];
        [self.contentView addSubview:self.categoryImageButton];
        [self.contentView addSubview:self.incomeLabel];
        [self.contentView addSubview:self.expenditureLabel];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.toplineView.height = self.height / 2;
    self.toplineView.centerX = self.width / 2;
    self.toplineView.top = 0;
    self.bottomlineView.height = self.height / 2;
    self.bottomlineView.centerX = self.width / 2;
    self.bottomlineView.bottom = self.height;
    self.categoryImageButton.size = CGSizeMake(6, 6);
    self.categoryImageButton.layer.cornerRadius = 3.f;
    self.categoryImageButton.centerY = self.height * 0.5;
    self.categoryImageButton.centerX = self.width * 0.5;
    self.incomeLabel.rightBottom = CGPointMake(self.categoryImageButton.left - 5, self.height);
    self.incomeLabel.centerY = self.height / 2;
    self.expenditureLabel.leftBottom = CGPointMake(self.categoryImageButton.right + 10, self.height);
    self.expenditureLabel.centerY = self.height / 2;
}

-(UILabel*)incomeLabel{
    if (!_incomeLabel) {
        _incomeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _incomeLabel.font = [UIFont systemFontOfSize:15];
        _incomeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _incomeLabel;
}

-(UILabel*)expenditureLabel{
    if (!_expenditureLabel) {
        _expenditureLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _expenditureLabel.font = [UIFont systemFontOfSize:15];
        _expenditureLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _expenditureLabel;
}

-(UIButton*)categoryImageButton{
    if (_categoryImageButton == nil) {
        _categoryImageButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 6, 6)];
        _categoryImageButton.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor];
        _categoryImageButton.contentMode = UIViewContentModeScaleAspectFill;
        _categoryImageButton.layer.masksToBounds = YES;
    }
    return _categoryImageButton;
}

-(UIView *)toplineView{
    if (!_toplineView) {
        _toplineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1 , self.height / 2 - 3)];
        _toplineView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor];
    }
    return _toplineView;
}

-(UIView *)bottomlineView{
    if (!_bottomlineView) {
        _bottomlineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1 , self.height / 2 - 3)];
        _bottomlineView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor];
    }
    return _bottomlineView;
}

-(void)setItem:(SSJBookKeepingHomeListItem *)item {
    _item = item;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *billDate=[dateFormatter dateFromString:item.date];
    long day = billDate.day;
    long month = billDate.month;
    long year = billDate.year;
    long currentMonth = [NSDate date].month;
    long currentYear = [NSDate date].year;
    _categoryImageButton.layer.borderWidth = 0;
    _categoryImageButton.userInteractionEnabled = NO;
    if (_item.balance < 0) {
        self.expenditureLabel.hidden = NO;
        self.incomeLabel.hidden = NO;
        self.incomeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        self.expenditureLabel.text = [NSString stringWithFormat:@"%.2f",_item.balance];
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
        self.incomeLabel.text = [NSString stringWithFormat:@"+%.2f",_item.balance];
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
}

-(void)shake {
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
            } completion:^(BOOL finished) {
                if (completion) {
                    completion();
                }
            }];
        }];
    }
}

- (void)updateCellAppearanceAfterThemeChanged {
    self.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    self.incomeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.expenditureLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.toplineView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor];
    self.bottomlineView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
