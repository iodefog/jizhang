//
//  SSJCustomTextView.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/2/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCustomTextView.h"
@interface SSJCustomTextView()

@property (nonatomic,strong) UILabel *placeholderLabel;

@end

@implementation SSJCustomTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor= [UIColor clearColor];
        self.placeholderColor= [UIColor ssj_colorWithHex:@"cccccc"];
        self.font= [UIFont systemFontOfSize:15];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self]; //通知:监听文字的改变
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.placeholderLabel.top =8;
    self.placeholderLabel.left =5;
    self.placeholderLabel.width =self.width - self.placeholderLabel.left*2.0;
    CGSize maxSize =CGSizeMake(self.placeholderLabel.width,MAXFLOAT);
    self.placeholderLabel.height= [self.placeholder boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.placeholderLabel.font} context:nil].size.height;
}

- (void)setText:(NSString*)text{
    [super setText:text];
    [self textDidChange];
    
}

-(void)setPlaceholder:(NSString *)placeholder{
    _placeholder = placeholder;
    self.placeholderLabel.text = _placeholder;
}

-(void)setPlaceholderColor:(UIColor *)placeholderColor{
    _placeholderColor= placeholderColor;
    self.placeholderLabel.textColor= _placeholderColor;
}

- (void)textDidChange {
    self.placeholderLabel.hidden = self.hasText;
}


-(UILabel *)placeholderLabel{
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc]init];
        _placeholderLabel.backgroundColor= [UIColor clearColor];
        _placeholderLabel.numberOfLines=0;
        [self addSubview:_placeholderLabel];
    }
    return _placeholderLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
