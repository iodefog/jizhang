//
//  SSJCreditCardEditeCell.h
//  SuiShouJi
//
//  Created by ricky on 16/8/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJCreditCardEditeCell : SSJBaseTableViewCell

typedef NS_ENUM(NSInteger, SSJCreditCardCellType) {
    SSJCreditCardCellTypeTextField,       //带输入的cell
    SSJCreditCardCellTypeDetail,          //带详情的cell
    SSJCreditCardCellTypeassertedDetail,  //带详情的cell
    SSJCreditCardCellTypeSubTitle,        //带副标题的cell
    SSJCreditCardCellColorSelect          //颜色选择
};

@property(nonatomic, strong) UITextField *textInput;

@property (nonatomic) SSJCreditCardCellType type;

@property (nonatomic,strong) NSString *cellImageName;

@property (nonatomic,strong) NSString *cellDetailImageName;

@property (nonatomic,strong) NSString *cellTitle;

@property (nonatomic,strong) NSString *cellSubTitle;

@property(nonatomic, strong) NSString *cellDetail;

@property(nonatomic, strong) NSAttributedString *cellAtrributedDetail;

@property(nonatomic, strong) NSString *cellColor;

@end
