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
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *textButton;
@property (weak, nonatomic) IBOutlet UIButton *otherTextButton;
@property (weak, nonatomic) IBOutlet UIImageView *otherIconView;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeHeightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherButtonWidthConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonWidthConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBtnHeightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherTextBtnHeightConst;


@end
@implementation SSJMoreProductAdviceTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
//    _iconView.image = [UIImage imageNamed:@"defualt_portrait"];
    [_iconView zy_cornerRadiusAdvance:15 rectCornerType:UIRectCornerAllCorners];
    [SSJPersonalDetailHelper queryUserDetailWithsuccess:^(SSJPersonalDetailItem *data) {
        if ([data.iconUrl hasPrefix:@"http"]) {
            [_iconView sd_setImageWithURL:[NSURL URLWithString:data.iconUrl] placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];
        }else{
            [_iconView sd_setImageWithURL:[NSURL URLWithString:SSJImageURLWithAPI(data.iconUrl)] placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];
        }
    } failure:^(NSError *error) {
        _iconView.image = [UIImage imageNamed:@"defualt_portrait"];
    }];
    
    _textButton.titleLabel.numberOfLines = 0;
    _otherTextButton.titleLabel.numberOfLines = 0;
    [_textButton.titleLabel setPreferredMaxLayoutWidth:SSJSCREENWITH - 2*(_iconView.width + 25)];
    [_otherTextButton.titleLabel setPreferredMaxLayoutWidth:SSJSCREENWITH - 2*(_iconView.width + 25)];
    
    _textButton.layer.cornerRadius = 5;
    _otherTextButton.layer.cornerRadius = 5;
    [_textButton clipsToBounds];
    [_otherTextButton clipsToBounds];
    _buttonWidthConst.constant = _otherButtonWidthConst.constant = SSJSCREENWITH - 2*(_iconView.width + 30);
}

+ (SSJMoreProductAdviceTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *cellId = @"SSJMoreProductAdviceTableViewCellId";
    SSJMoreProductAdviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SSJMoreProductAdviceTableViewCell" owner:nil options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)setMessage:(SSJChatMessageItem *)message
{
    _message = message;
    
    if (message.isHiddenTime == YES) { // 隐藏时间
        self.timeLabel.hidden = YES;
        _timeHeightConst.constant = 0;
    } else { // 显示时间
        self.timeLabel.text = message.dateStr;
        self.timeLabel.hidden = NO;
        _timeHeightConst.constant = 21;
    }
    if (message.isSystem == NO) {//建议
        [self settingShowTextButton:self.textButton showIconView:self.iconView hideTextButton:self.otherTextButton hideIconView:self.otherIconView];
    }else{//系统回复
        [self settingShowTextButton:self.otherTextButton showIconView:self.otherIconView hideTextButton:self.textButton hideIconView:self.iconView];
        
    }
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
    // 设置按钮的高度就是titleLabel的高度
    CGFloat buttonH = [self heightOfString:showTextButton.titleLabel.text font:[UIFont systemFontOfSize:16] width:SSJSCREENWITH - 2*(_iconView.width + 30)] + 20;
    _textBtnHeightConst.constant = buttonH;
    _otherTextBtnHeightConst.constant = buttonH;
    
    // 强制更新
    [showTextButton layoutIfNeeded];
    
    // 计算当前cell的高度
    CGFloat timeH = self.message.isHiddenTime == YES ? 0 : 21;
    CGFloat buttonMaxY = showTextButton.height + timeH;
    self.message.cellHeight = buttonMaxY + 15 ;
}

//字符串文字的高度
- (CGFloat)heightOfString:(NSString *)string font:(UIFont *)font width:(CGFloat)width
{
    CGRect bounds;
    NSDictionary * parameterDict=[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    bounds=[string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:parameterDict context:nil];
    return bounds.size.height;
}

@end
