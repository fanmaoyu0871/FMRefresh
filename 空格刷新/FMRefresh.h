//
//  FMRefresh.h
//  空格refresh
//
//  Created by 范茂羽 on 16/1/6.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FMRefreshType){
    FMRefresh_Default_Type = 1, //默认父视图为tableView
    FMRefresh_Backgroud_Type    //父视图为tableView.backgroundView

};

typedef NS_ENUM(NSInteger, FMRefreshState){
    FMRefreshStateNormal = 1,
    FMRefreshStatePulling = 2,
    FMRefreshStateRefreshing = 3
};

@interface FMRefresh : UIView

@property (nonatomic, assign)FMRefreshType refreshType;

+(instancetype)headerWithRefreshingBlock:(void (^)())block type:(FMRefreshType)type;

-(void)beginRefreshing;

-(void)endRefreshing;

@end
