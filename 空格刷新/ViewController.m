//
//  ViewController.m
//  空格refresh
//
//  Created by 范茂羽 on 16/1/6.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+Refresh.h"

#define FMWeakSelf   __weak typeof(self) weakSelf = self;

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    FMWeakSelf
    self.tableView.header = [FMRefresh headerWithRefreshingBlock:^{
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 3*NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [weakSelf.tableView.header endRefreshing];
        });
    } type:FMRefresh_Backgroud_Type];
    
    [self.tableView.header beginRefreshing];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc]init];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
