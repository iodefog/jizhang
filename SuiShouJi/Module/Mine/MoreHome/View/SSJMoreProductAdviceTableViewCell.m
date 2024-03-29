//
//  SSJMoreProductAdviceTableViewCell.m
//  SuiShouJi
//
//  Created by yi cai on 2016/12/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMoreProductAdviceTableViewCell.h"
#import "SSJChatMessageItem.h"
#import "SSJPersonalDetailHelper.h"
#import "UIImageView+CornerRadius.h"
@interface SSJMoreProductAdviceTableViewCell()

@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIButton *textButton;
@property (strong, nonatomic) UIButton *otherTextButton;
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UIImageView *otherIconView;
/**
 timeLabel的高度
 */
@property (nonatomic, assign) CGFloat timeLabelHeight;

@end
@implementation SSJMoreProductAdviceTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.textButton];
        [self.contentView addSubview:self.otherIconView];
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.otherTextButton];
        //头像
        [SSJPersonalDetailHelper queryUserDetailWithsuccess:^(SSJPersonalDetailItem *data) {
            if ([data.iconUrl hasPrefix:@"http"]) {
                [self.iconView sd_setImageWithURL:[NSURL URLWithString:data.iconUrl] placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];
            }else{
                [self.iconView sd_setImageWithURL:[NSURL URLWithString:SSJImageURLWithAPI(data.iconUrl)] placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];
            }
        } failure:^(NSError *error) {
            self.iconView.image = [UIImage imageNamed:@"defualt_portrait"];
        }];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.timeLabel.leftTop = CGPointMake(0, 10);
    self.timeLabel.width = self.width;
    self.otherIconView.left = 20;
    self.otherTextButton.left = CGRectGetMaxX(self.otherIconView.frame) + 10;
    self.iconView.right = self.width - 20;
    self.textButton.right = CGRectGetMinX(self.iconView.frame) - 10;
    
}

- (void)displayFrame
{
//    self.otherTextButton.top = self.timeLabelHeight + 10;
    self.otherTextButton.top = self.otherIconView.top = self.textButton.top = self.iconView.top = self.timeLabelHeight + 10;
}

+ (SSJMoreProductAdviceTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *cellId = @"SSJMoreProductAdviceTableViewCellId";
    SSJMoreProductAdviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SSJMoreProductAdviceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)setMessage:(SSJChatMessageItem *)message
{
    _message = message;
    
    if (message.isHiddenTime == YES) { // 隐藏时间
        self.timeLabel.hidden = YES;
        self.timeLabel.height = self.timeLabelHeight = 0;
    } else { // 显示时间
        self.timeLabel.text = message.dateStr;
        self.timeLabel.hidden = NO;
        self.timeLabel.height = self.timeLabelHeight = 21;
    }
    if (message.isSystem == NO) {//建议
        [self settingShowTextButton:self.textButton showIconView:self.iconView hideTextButton:self.otherTextButton hideIconView:self.otherIconView];
    }else{//系统回复
        [self settingShowTextButton:self.otherTextButton showIconView:self.otherIconView hideTextButton:self.textButton hideIconView:self.iconView];
    }
    [self displayFrame];//布局frame
}

/**
 * 处理左右按钮、头像
 */
- (void)settingShowTextButton:(UIButton *)showTextButton showIconView:(UIImageView *)showIconView hideTextButton:(UIButton *)hideTextButton hideIconView:(UIImageView *)hideIconView
{
    hideTextButton.hidden = YES;
    hideIconView.hidden = YES;
    
    showTextButton.hidden = NO;
    showIconView.hidden = NO;
    
    // 设置按钮的文字
    if (self.message.isSystem == NO) {//建议
        [showTextButton setTitle:self.message.content forState:UIControlStateNormal];
    }else if(self.message.isSystem == YES){//系统
        [showTextButton setTitle:self.message.content forState:UIControlStateNormal];
    }
    
    CGSize size = [self sizeOfString:showTextButton.titleLabel.text font:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3] width:SSJSCREENWITH - 2*(_iconView.width + 30)];
    // 设置按钮的高度就是titleLabel的高度
    CGFloat buttonH = size.height + 20;
    CGFloat buttonW = size.width + 20;
    showTextButton.height = buttonH;
    showTextButton.width = buttonW;
    hideTextButton.height = 0;
    hideTextButton.width = 0;
    
    // 计算当前cell的高度
    CGFloat timeH = self.message.isHiddenTime == YES ? 0 : 21;
    CGFloat buttonMaxY = showTextButton.height + timeH;
    self.message.cellHeight = buttonMaxY + 15 ;
}

//字符串文字的高度
- (CGSize)sizeOfString:(NSString *)string font:(UIFont *)font width:(CGFloat)width
{
    CGRect bounds;
    NSDictionary * parameterDict=[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    bounds=[string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:parameterDict context:nil];
    return bounds.size;
}

#pragma mark - Lazy
- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        _timeLabel.textColor = [UIColor ssj_colorWithHex:@"999999"];
    }
    return _timeLabel;
}

- (UIButton *)textButton
{
    if (!_textButton) {
        _textButton = [[UIButton alloc] init];
        _textButton.backgroundColor = [UIColor ssj_colorWithHex:@"DDDDDD"];
        _textButton.layer.cornerRadius = 5;
        _textButton.titleLabel.numberOfLines = 0;
        _textButton.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [_textButton clipsToBounds];
        [_textButton setTitleColor:[UIColor ssj_colorWithHex:@"333333"] forState:UIControlStateNormal];
        _textButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_textButton.titleLabel setPreferredMaxLayoutWidth:SSJSCREENWITH - 2*(_iconView.width + 25)];
    }
    return _textButton;
}

- (UIButton *)otherTextButton
{
    if (!_otherTextButton) {
        _otherTextButton = [[UIButton alloc] init];
        _otherTextButton.backgroundColor = [UIColor ssj_colorWithHex:@"FDEDEF"];
        _otherTextButton.layer.cornerRadius = 5;
        _otherTextButton.titleLabel.numberOfLines = 0;
        _otherTextButton.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [_otherTextButton clipsToBounds];
        [_otherTextButton setTitleColor:[UIColor ssj_colorWithHex:@"333333"] forState:UIControlStateNormal];
        _otherTextButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_otherIconView clipsToBounds];
        [_otherTextButton.titleLabel setPreferredMaxLayoutWidth:SSJSCREENWITH - 2*(_iconView.width + 25)];
    }
    return _otherTextButton;
}

- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.size = CGSizeMake(30, 30);
        [_iconView zy_cornerRadiusAdvance:15 rectCornerType:UIRectCornerAllCorners];
    }
    return _iconView;
}

- (UIImageView *)otherIconView
{
    if (!_otherIconView) {
        _otherIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"more_productAdvice_system"]];
        _otherIconView.size = CGSizeMake(30, 30);
        
    }
    return _otherIconView;
}

@end
