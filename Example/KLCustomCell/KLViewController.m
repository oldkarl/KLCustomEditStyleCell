//
//  KLViewController.m
//  KLCustomCell
//
//  Created by karl on 12/01/2016.
//  Copyright (c) 2016 karl. All rights reserved.
//

#import "KLViewController.h"
#import "tableViewCell.h"

static NSString *myCellIdentifier = @"myCell";

@interface KLViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (readwrite, nonatomic, strong) UITableView * tableView;

@end

@implementation KLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.tableView];
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        [_tableView registerClass:[tableViewCell class] forCellReuseIdentifier:myCellIdentifier];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    tableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCellIdentifier];
    [cell.textLabel setText:[NSString stringWithFormat:@"%ld",indexPath.row]];
    cell.editStyleBackGroundColors = @[[UIColor darkGrayColor],[UIColor lightGrayColor]];
    cell.editStyleItems = @[
                            @{@"iconName":@"icon_edit_white_line",@"title":@"编辑"},
                            @{@"iconName":@"icon_delet_white_line",@"title":@"删除"}
                            ];
    cell.itemWidth = 80.0f;

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
