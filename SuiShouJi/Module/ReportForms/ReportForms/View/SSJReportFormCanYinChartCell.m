//
//  SSJReportFormCanYinChartCell.m
//  SuiShouJi
//
//  Created by yi cai on 2016/12/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormCanYinChartCell.h"
@interface SSJReportFormCanYinChartCell()
/**
 圆圈背景图层
 */
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *ratioLabel;
@property (nonatomic, strong) UILabel *amountLabel;
@property (nonatomic, strong) CAShapeLayer *topLineLayer;
@property (nonatomic, strong) CAShapeLayer *bottomLineLayer;
@property (nonatomic, strong) CAShapeLayer *circleLayer1;
@property (nonatomic, strong) CAShapeLayer *circleLayer2;
@property (nonatomic, strong) CAShapeLayer *circleLayer3;

@end
@implementation SSJReportFormCanYinChartCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView.layer addSublayer:self.topLineLayer];
        [self.contentView.layer addSublayer:self.bottomLineLayer];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.ratioLabel];
        [self.contentView addSubview:self.amountLabel];
        self.dateLabel.font = self.ratioLabel.font = self.amountLabel.font = [UIFont systemFontOfSize:14];
    }
    return self;
}

- (void)setImageColor:(NSString *)imageColor
{
    _imageColor = imageColor;
    [self drawCircleWithColor:imageColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.dateLabel.centerY = self.ratioLabel.centerY = self.amountLabel.centerY = self.centerY;
    self.dateLabel.left = 30;
    self.ratioLabel.centerX = self.centerX;
    self.amountLabel.right = self.width - 30;
}

+ (SSJReportFormCanYinChartCell *)cellWithTableView:(UITableView *)tableView
{
   static NSString *cellId = @"SSJReportFormCanYinChartCellId";
    SSJReportFormCanYinChartCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SSJReportFormCanYinChartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    self.topLineLayer.hidden = indexPath.row == 0;
    self.bottomLineLayer.hidden = indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1;
}

/*
 *画实线圆
 */

- (void)drawCircleWithColor:(NSString *)colorStr
{
    //    第一层直径20px 30%  第二层直径14px 30%   中间最小的点实色 直径8px
    CGRect frame1 = CGRectMake(10, (self.frame.size.height - 10)*0.5, 10, 10);//最外面
    CGRect frame2 = CGRectMake(11.5, (self.frame.size.height - 7)*0.5, 7, 7);
    CGRect frame3 = CGRectMake(13, (self.frame.size.height - 4)*0.5, 4, 4);
    UIColor *color1 = [UIColor ssj_colorWithHex:colorStr alpha:0.3];
    UIColor *color2 = color1;
    UIColor *color3 = [UIColor ssj_colorWithHex:colorStr];;
    /*
     *画实线圆
     */
    CGMutablePathRef solidPath1 =  CGPathCreateMutable();
    self.circleLayer1.fillColor = color2.CGColor;
    CGPathAddEllipseInRect(solidPath1, nil, frame1);
    self.circleLayer1.path = solidPath1;
    CGPathRelease(solidPath1);
    
    
    CGMutablePathRef solidPath2 =  CGPathCreateMutable();
    self.circleLayer2.fillColor = color2.CGColor;
    CGPathAddEllipseInRect(solidPath2, nil, frame2);
    self.circleLayer2.path = solidPath2;
    CGPathRelease(solidPath2);
    
    
    CGMutablePathRef solidPath3 =  CGPathCreateMutable();
    self.circleLayer3.fillColor = color3.CGColor;
    CGPathAddEllipseInRect(solidPath3, nil, frame3);
    self.circleLayer3.path = solidPath3;
    CGPathRelease(solidPath3);
}


#pragma mark - Lazy
- (CAShapeLayer *)topLineLayer
{
    if (!_topLineLayer) {
        _topLineLayer = [CAShapeLayer layer];
        CGMutablePathRef solidShapePath =  CGPathCreateMutable();
        [_topLineLayer setFillColor:[[UIColor clearColor] CGColor]];
        [_topLineLayer setStrokeColor:[[UIColor orangeColor] CGColor]];
        _topLineLayer.lineWidth = 2.0f ;
        CGPathMoveToPoint(solidShapePath, NULL, 15, 0);
        CGPathAddLineToPoint(solidShapePath, NULL, 15,self.height*0.5);
        [_topLineLayer setPath:solidShapePath];
        CGPathRelease(solidShapePath);
        _bottomLineLayer.hidden = YES;
    }
    return _topLineLayer;
}

- (CAShapeLayer *)bottomLineLayer
{
    if (!_bottomLineLayer) {
        _bottomLineLayer = [CAShapeLayer layer];
        CGMutablePathRef solidShapePath =  CGPathCreateMutable();
        [_bottomLineLayer setFillColor:[[UIColor clearColor] CGColor]];
        [_bottomLineLayer setStrokeColor:[[UIColor orangeColor] CGColor]];
        _bottomLineLayer.lineWidth = 1.0f ;
        CGPathMoveToPoint(solidShapePath, NULL, 15, self.height*0.5);
        CGPathAddLineToPoint(solidShapePath, NULL, 15,self.height);
        [_bottomLineLayer setPath:solidShapePath];
        CGPathRelease(solidShapePath);
        _bottomLineLayer.hidden = YES;
    }
    return _bottomLineLayer;
}
- (CAShapeLayer *)circleLayer1
{
    if (!_circleLayer1) {
        _circleLayer1 =  [CAShapeLayer layer];
    }
    return _circleLayer1;
}

- (CAShapeLayer *)circleLayer2
{
    if (!_circleLayer2) {
        _circleLayer2 =  [CAShapeLayer layer];
    }
    return _circleLayer2;
}

- (CAShapeLayer *)circleLayer3
{
    if (!_circleLayer3) {
        _circleLayer3 =  [CAShapeLayer layer];
    }
    return _circleLayer3;
}

- (UILabel *)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
    }
    return _dateLabel;
}

- (UILabel *)ratioLabel
{
    if (!_ratioLabel) {
        _ratioLabel = [[UILabel alloc] init];
    }
    return _ratioLabel;
}

- (UILabel *)amountLabel
{
    if (!_amountLabel) {
        _amountLabel = [[UILabel alloc] init];
    }
    return _amountLabel;
}

- (void)updateCellAppearanceAfterThemeChanged
{
   self.ratioLabel.textColor = self.amountLabel.textColor = self.dateLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    
}

/*
- (void)drawRect:(CGRect)rect
{
    //    第一层直径20px 30%  第二层直径14px 30%   中间最小的点实色 直径8px
    CGRect frame1 = CGRectMake(10, (self.height - 10)*0.5, 10, 10);//最外面
    CGRect frame2 = CGRectMake(11.5, (self.height - 7)*0.5, 7, 7);
    CGRect frame3 = CGRectMake(13, (self.height - 4)*0.5, 4, 4);
    UIColor *color1 = [UIColor ssj_colorWithHex:self.imageColor alpha:0.3];
    UIColor *color2 = color1;
    UIColor *color3 = [UIColor ssj_colorWithHex:self.imageColor];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.0);
    CGContextAddEllipseInRect(context, frame1);//在这个框中画圆
    [color1 set];
    CGContextFillPath(context);
    
    CGContextAddEllipseInRect(context, frame2);//在这个框中画圆
    CGContextFillPath(context);
    [color2 set];
    CGContextAddEllipseInRect(context, frame3);//在这个框中画圆
    [color3 set];
    CGContextFillPath(context);
}
*/

@end
