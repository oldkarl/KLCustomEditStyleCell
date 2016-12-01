//
//  KLCustomEditStyleCell.m
//  KLCustomEditStyleCell_Demo
//
//  Created by karlliu on 16/11/6.
//  Copyright © 2016年 karlliu. All rights reserved.
//

#import "KLCustomEditStyleCell.h"
#import "objc/runtime.h"

static char editIndexPathKey;

@interface KLCustomEditStyleCell()<UIGestureRecognizerDelegate>

@property(nonatomic)float originX;
@property(nonatomic)CGPoint startPoint;
@property(strong,nonatomic)NSMutableArray *imageArray;

@end

@implementation KLCustomEditStyleCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
    
        _itemWidth = 50;
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(panHandler:)];
        panGestureRecognizer.delegate = self;
        panGestureRecognizer.delaysTouchesBegan = YES;
        [self addGestureRecognizer:panGestureRecognizer];
        
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

-(void)panHandler:(UIPanGestureRecognizer *)gestureRecognizer{
    
    UITableView *tableView = (UITableView *)[[self superview] superview];
    
    KLCustomEditStyleCell *cell = objc_getAssociatedObject(tableView, &editIndexPathKey);
    if(cell && cell != self){
        [self becomeNormal];
//        return;
    }
    
    CGPoint translation = [gestureRecognizer translationInView:self];
    
    // Check for horizontal gesture
    if (fabs(translation.x) < fabs(translation.y))
    {
        return;
    }
    
    CGPoint point = [gestureRecognizer locationInView:self];
    
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
    
        _originX = self.contentView.frame.origin.x;
        _startPoint = point;
    }
    if(gestureRecognizer.state == UIGestureRecognizerStateChanged){
       
        if (fabs(translation.x)-fabs(translation.y)>10)
        {
            [self addEditView];
        }
        
        float x = point.x - _startPoint.x;
        x = MIN(0, _originX+x);
        self.contentView.frame = CGRectMake(x, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height);
    }
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        
        
        float x = self.contentView.frame.origin.x;
        [self showOrHide:x];
        
    }
}
-(void)showOrHide:(float)x{
    
    float minX = - _itemWidth*_editStyleBackGroundColors.count;
    
    if(x<minX/2){
        
        x = minX;
    }
    else
        x = 0;
    
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.contentView.frame = CGRectMake(x, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        if(x==0){
            [self becomeNormal];
        }
        else
            [self removeGestureRecognizer];
    }];

}
-(void)addEditView{
    
    UITableView *tableView = (UITableView *)[[self superview] superview];
    tableView.scrollEnabled = NO;
    UIView *editView = [self viewWithTag:1001];
    if(editView)
        return;
    
    _imageArray = [NSMutableArray new];
   
    float width = _itemWidth*_editStyleBackGroundColors.count;
    editView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-width, 0, width, self.frame.size.height)];
    editView.tag = 1001;
    
    for (int i = 0; i<_editStyleBackGroundColors.count; i++) {
        UIColor *tempColor = _editStyleBackGroundColors[i];
        UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(i*_itemWidth, 0, _itemWidth,  self.frame.size.height-1)];
        [itemView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTap:)]];
        itemView.tag = i;
        itemView.backgroundColor = tempColor;
        [editView addSubview:itemView];
        [self addCustomView:i itemView:itemView];
    }
    
    [self insertSubview:editView belowSubview:self.contentView];
    [self bringSubviewToFront:self.contentView];
}
-(void)addCustomView:(int)index itemView:(UIView *)itemView{

    if(index>=_editStyleItems.count)
        return;
    
    NSDictionary *item = _editStyleItems[index];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    imageView.image = [UIImage imageNamed:[item valueForKey:@"iconName"]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    imageView.center = CGPointMake(itemView.frame.size.width/2, itemView.frame.size.height/2-5);
    [itemView addSubview:imageView];
    
    [_imageArray addObject:imageView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(5,CGRectGetMaxY(imageView.frame)+5, CGRectGetWidth(itemView.frame)-10,14)];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:10.0f];
    title.textColor = [UIColor whiteColor];
    title.text  = [item valueForKey:@"title"];
    
    [itemView addSubview:title];
}
-(void)itemTap:(UITapGestureRecognizer *)tapGestureRecognizer{
    
    int tag = (int)tapGestureRecognizer.view.tag;
    UITableView *tableView = (UITableView *)[[self superview] superview];
    NSIndexPath *indexPath = [tableView indexPathForCell:self];
    if([self.delegate respondsToSelector:@selector(customEditStyleAction:indexPath:index:)]){
        if(tag==0)
            [self becomeNormal];
        [self.delegate customEditStyleAction:tableView indexPath:indexPath index:tag];
    }
}
-(void)removeGestureRecognizer{

    UITableView *tableView = (UITableView *)[[self superview] superview];
    tableView.scrollEnabled = YES;
    objc_setAssociatedObject(tableView, &editIndexPathKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

     UITableView *tableView = (UITableView *)[[self superview] superview];
    KLCustomEditStyleCell *cell = objc_getAssociatedObject(tableView, &editIndexPathKey);
    if(cell){
       [self becomeNormal];
    }
    else{
        [super touchesBegan:touches withEvent:event];
    }
}
-(void)becomeNormal{

    UITableView *tableView = (UITableView *)[[self superview] superview];
    KLCustomEditStyleCell *cell = objc_getAssociatedObject(tableView, &editIndexPathKey);
    if(cell){
    
        objc_setAssociatedObject(tableView, &editIndexPathKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            cell.contentView.frame = CGRectMake(0, cell.contentView.frame.origin.y, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
            
        } completion:^(BOOL finished) {
            tableView.scrollEnabled = YES;
            UIView *editView = [cell viewWithTag:1001];
            [editView removeFromSuperview];
        }];

    }
    else{

        tableView.scrollEnabled = YES;
    }
    
}
-(void)showTip{

    [self addEditView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{  
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            self.contentView.frame = CGRectMake(-_itemWidth*3/4, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height);
            
        } completion:^(BOOL finished) {
            
            [self removeGestureRecognizer];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [self becomeNormal];
            });
            
        }];
    });
}
-(void)earthquake:(UIView*)itemView
{
    CGFloat t =1.0;
    
    CGAffineTransform leftQuake  =CGAffineTransformTranslate(CGAffineTransformIdentity, t,-t);
    CGAffineTransform rightQuake =CGAffineTransformTranslate(CGAffineTransformIdentity,-t, t);
    
    itemView.transform = leftQuake;  // starting point
    
    [UIView beginAnimations:@"earthquake" context:(__bridge void * _Nullable)(itemView)];
    [UIView setAnimationRepeatAutoreverses:YES];// important
    [UIView setAnimationRepeatCount:4];
    [UIView setAnimationDuration:0.07];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(earthquakeEnded:finished:context:)];
    
    itemView.transform = rightQuake;// end here & auto-reverse
    
    [UIView commitAnimations];
}

-(void)earthquakeEnded:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
    if([finished boolValue])
    {
        UIView* item =(__bridge UIView*)context;
        item.transform = CGAffineTransformIdentity;
    }
}
#pragma mark setter
-(void)setEditStyleBackGroundColors:(NSArray *)editStyleBackGroundColors{

    _editStyleBackGroundColors = editStyleBackGroundColors;
}
-(void)setEditStyleItems:(NSArray *)editStyleItems{

    _editStyleItems = editStyleItems;
}
@end
