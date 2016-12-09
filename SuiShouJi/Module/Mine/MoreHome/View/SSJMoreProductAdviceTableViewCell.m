//
//  SSJMoreProductAdviceTableViewCell.m
//  SuiShouJi
//
//  Created by yi cai on 2016/12/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMoreProductAdviceTableViewCell.h"
#import "SSJChatMessageItem.h"
@interface SSJMoreProductAdviceTableViewCell()
@property (strong, nonatomic)  UILabel *timeLabel;
@property (strong, nonatomic)  UIButton *textButton;
@property (strong, nonatomic)  UIImageView *iconView;
@property (strong, nonatomic)  UIButton *otherTextButton;
@property (strong, nonatomic)  UIImageView *otherIconView;
@end
@implementation SSJMoreProductAdviceTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.textButton];
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.otherTextButton];
        [self.contentView addSubview:self.otherIconView];
    }
    return self;
}

- (void)setMessage:(SSJChatMessageItem *)message
{
    _message = message;
    if (self.message.cContent.length && !self.message.creplyContent.length) {//建议
        message.isSystem = NO;
    }else if(!self.message.cContent.length && self.message.creplyContent.length){//系统回复
        message.isSystem = YES;
    }
    if (message.isSystem == NO) { // 右边
        [self settingShowTextButton:self.textButton showIconView:self.iconView hideTextButton:self.otherTextButton hideIconView:self.otherIconView];
    } else { // 左边
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
    if (self.message.cContent.length && !self.message.creplyContent.length) {//建议
        [showTextButton setTitle:self.message.cContent forState:UIControlStateNormal];
    }else if(!self.message.cContent.length && self.message.creplyContent.length){
        [showTextButton setTitle:self.message.creplyContent forState:UIControlStateNormal];
    }
    
    // 设置按钮的高度就是titleLabel的高度
    CGFloat buttonH = showTextButton.titleLabel.frame.size.height;
    showTextButton.height = buttonH;
    
    // 强制更新
    [showTextButton layoutIfNeeded];
    
    // 计算当前cell的高度
    CGFloat buttonMaxY = CGRectGetMaxY(showTextButton.frame);
    CGFloat iconMaxY = CGRectGetMaxY(showIconView.frame);
    self.message.cellHeight = MAX(buttonMaxY, iconMaxY) + 10;
}

#pragma mark -Lazy
- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
    }
    return _timeLabel;
}

- (UIButton *)textButton
{
    if (!_textButton) {
        _textButton = [[UIButton alloc] init];
    }
    return _textButton;
}

- (UIButton *)otherTextButton
{
    if (!_otherTextButton) {
        _otherTextButton = [[UIButton alloc] init];
    }
    return _otherTextButton;
}

- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
    }
    return _iconView;
}


- (UIImageView *)otherIconView
{
    if (!_otherIconView) {
        _otherIconView = [[UIImageView alloc] init];
    }
    return _otherIconView;
}


@end
