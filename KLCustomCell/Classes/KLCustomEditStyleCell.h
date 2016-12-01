//
//  KLCustomEditStyleCell.h
//  KLCustomEditStyleCell_Demo
//
//  Created by karlliu on 16/11/6.
//  Copyright © 2016年 karlliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KLCustomEditStyleActionDelegate <NSObject>

-(void)customEditStyleAction:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath index:(int)index;

@end

@interface KLCustomEditStyleCell : UITableViewCell

@property(nonatomic,strong)NSArray *editStyleBackGroundColors;
@property(nonatomic,strong)NSArray *editStyleItems;
@property(nonatomic)float itemWidth;

@property(nonatomic,weak)id<KLCustomEditStyleActionDelegate> delegate;

-(void)showTip;
-(void)becomeNormal;
@end
