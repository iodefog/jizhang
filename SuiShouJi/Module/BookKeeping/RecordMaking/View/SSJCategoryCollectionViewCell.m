//
//  SSJCategoryCollectionViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/21.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCategoryCollectionViewCell.h"
#import "SSJDatabaseQueue.h"
#import "FMDB.h"

@interface SSJCategoryCollectionViewCell()
@property (strong, nonatomic) UIButton *editButton;
@end
@implementation SSJCategoryCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.EditeModel = NO;
        self.categorySelected = NO;
        [self.contentView addSubview:self.backView];
        [self.backView addSubview:self.categoryImage];
        [self.contentView addSubview:self.categoryName];
        [self addSubview:self.editButton];
        if (![self.item.categoryTitle isEqualToString:@"添加"]) {
            [self addLongPressGesture];
        }
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.backView.centerX = self.width / 2;
    self.backView.top = 3;
    self.categoryImage.center = CGPointMake(self.backView.width / 2, self.backView.height / 2);
    self.categoryName.bottom = self.height - 2;
    self.categoryName.centerX = self.width / 2;
}

-(UIImageView*)categoryImage{
    if (!_categoryImage) {
        _categoryImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 34, 34)];
    }
    return _categoryImage;
}

-(UILabel*)categoryName{
    if (!_categoryName) {
        _categoryName = [[UILabel alloc]init];
        [_categoryName sizeToFit];
        _categoryName.font = [UIFont systemFontOfSize:14];
        _categoryName.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _categoryName.textAlignment = NSTextAlignmentCenter;
    }
    return _categoryName;
}

-(UIButton *)editButton{
    if (!_editButton) {
        _editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 12, 12)];
        [_editButton setImage:[UIImage imageNamed:@"bt_delete"] forState:UIControlStateNormal];
        _editButton.layer.cornerRadius = 6.0f;
        _editButton.layer.masksToBounds = YES;
        _editButton.hidden = YES;
        [_editButton addTarget:self action:@selector(removeCategory:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}

-(UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        _backView.layer.cornerRadius = 25.f;
        _backView.backgroundColor = [UIColor clearColor];
    }
    return _backView;
}

-(void)setItem:(SSJRecordMakingCategoryItem *)item{
    _item = item;
    [self setNeedsLayout];
    _categoryName.text = _item.categoryTitle;
    [_categoryName sizeToFit];
    _categoryImage.image = [UIImage imageNamed:self.item.categoryImage];
}

-(void)addLongPressGesture{
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
        longPressGr.minimumPressDuration = 1.0;
        [self addGestureRecognizer:longPressGr];
}

-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture{
    if (self.longPressBlock) {
        self.longPressBlock();
    }
}

-(void)setEditeModel:(BOOL)EditeModel{
    _EditeModel = EditeModel;
    if (_EditeModel == YES && ![self.item.categoryTitle isEqualToString:@"添加"]) {
        self.editButton.hidden = NO;
    }else{
        self.editButton.hidden = YES;
    }
}

-(void)removeCategory:(id)sender{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db){
        [db executeUpdate:@"UPDATE BK_USER_BILL SET ISTATE = 0 , CWRITEDATE = ? , IVERSION = ? , OPERATORTYPE = ? WHERE CBILLID = ? AND CUSERID = ? ",[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[NSNumber numberWithLongLong:SSJSyncVersion()],[NSNumber numberWithInt:1],self.item.categoryID,SSJUSERID()];
        SSJDispatch_main_async_safe(^(){
            if (weakSelf.removeCategoryBlock) {
                weakSelf.removeCategoryBlock();
            }
        });
    }];

}


-(void)setCategorySelected:(BOOL)categorySelected{
    _categorySelected = categorySelected;
    if (categorySelected == YES) {
        self.backView.layer.borderWidth = 1;
        self.backView.layer.borderColor = [UIColor ssj_colorWithHex:self.item.categoryColor].CGColor;
    }else{
        self.backView.layer.borderWidth = 0;
    }
}

@end
