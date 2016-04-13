
//
//  SSJHomeBudgetButton.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJHomeBudgetButton.h"
#import "SSJBudgetWaveWaterView.h"

@interface SSJHomeBudgetButton()
@property (nonatomic,strong) UIImageView *addBudgetView;
@property (nonatomic,strong) SSJBudgetWaveWaterView *budgetWaveScaleView;
@property (nonatomic,strong) UILabel *budgetLabel;
@end
@implementation SSJHomeBudgetButton

- (void)dealloc {
    [self.budgetWaveScaleView stopWave];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.addBudgetView];
        [self addSubview:self.budgetWaveScaleView];
        [self addSubview:self.budgetLabel];
        [self addSubview:self.button];
    }
    return self;
}

-(void)layoutSubviews{
    self.button.size = self.size;
    self.button.leftTop = CGPointMake(0, 0);
    self.addBudgetView.size = CGSizeMake(30, 30);
    self.addBudgetView.left = 0;
    self.budgetWaveScaleView.frame = self.addBudgetView.frame;
    self.addBudgetView.centerY = self.height / 2;
    self.budgetLabel.left = self.addBudgetView.right + 10;
    self.budgetLabel.centerY = self.height / 2;
}

-(UIImageView *)addBudgetView{
    if (!_addBudgetView) {
        _addBudgetView = [[UIImageView alloc]init];
        _addBudgetView.tintColor = [UIColor whiteColor];
        _addBudgetView.image = [[UIImage imageNamed:@"add"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return _addBudgetView;
}

-(UILabel *)budgetLabel{
    if (!_budgetLabel) {
        _budgetLabel = [[UILabel alloc]init];
        _budgetLabel.textColor = [UIColor whiteColor];
        _budgetLabel.textAlignment = NSTextAlignmentLeft;
        _budgetLabel.font = [UIFont systemFontOfSize:14];
    }
    return _budgetLabel;
}

-(SSJBudgetWaveWaterView *)budgetWaveScaleView{
    if (!_budgetWaveScaleView) {
        _budgetWaveScaleView = [[SSJBudgetWaveWaterView alloc]init];
        _budgetWaveScaleView.clipsToBounds = YES;
        _budgetWaveScaleView.waveAmplitude = 2;
        _budgetWaveScaleView.waveSpeed = 2;
        _budgetWaveScaleView.waveCycle = 0.8;
        _budgetWaveScaleView.waveGrowth = 1;
        _budgetWaveScaleView.waveOffset = 10;
        _budgetWaveScaleView.fullWaveAmplitude = 1;
        _budgetWaveScaleView.fullWaveSpeed = 2;
        _budgetWaveScaleView.fullWaveCycle = 4;
        _budgetWaveScaleView.showText = NO;
        _budgetWaveScaleView.outerBorderWidth = 1;
        _budgetWaveScaleView.innerBorderWidth = 0.5;
    }
    return _budgetWaveScaleView;
}

-(UIButton *)button{
    if (!_button) {
        _button = [[UIButton alloc]init];
        [_button addTarget:self action:@selector(budgetButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

-(void)setModel:(SSJBudgetModel *)model{
    _model = model;
    if (_model == nil) {
        self.budgetWaveScaleView.hidden = YES;
        self.addBudgetView.hidden = NO;
        self.budgetLabel.text = @"预算";
        [self.budgetLabel sizeToFit];
    }else{
        self.budgetWaveScaleView.hidden = NO;
        self.addBudgetView.hidden = YES;
        if (model.budgetMoney < model.payMoney) {
            self.budgetLabel.text = [NSString stringWithFormat:@"超支%.2f",model.budgetMoney - model.payMoney];
            [self.budgetLabel sizeToFit];
            self.budgetWaveScaleView.percent = 1.1;
        }else{
            self.budgetLabel.text = [NSString stringWithFormat:@"剩余%.2f",model.budgetMoney - model.payMoney];
            [self.budgetLabel sizeToFit];
            self.budgetWaveScaleView.percent = (1 - (model.budgetMoney - model.payMoney)/ model.budgetMoney);
        }
    }
}

-(void)budgetButtonClick:(id)sender{
    if (self.budgetButtonClickBlock) {
        self.budgetButtonClickBlock(self.model);
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
