//
//  SSJFixedFinancePrductListTableViewCell.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinancePrductListTableViewCell.h"

@implementation SSJFixedFinancePrductListTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *cellId = @"SSJFixedFinancePrductListTableViewCellId";
    SSJFixedFinancePrductListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SSJFixedFinancePrductListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];;
    }
    return cell;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}
@end
