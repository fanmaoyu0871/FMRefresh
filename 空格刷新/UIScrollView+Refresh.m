//
//  UIScrollView+Refresh.m
//  空格refresh
//
//  Created by 范茂羽 on 16/1/7.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import "UIScrollView+Refresh.h"
#import <objc/runtime.h>

@implementation UIScrollView (Refresh)

static const char key = '\0';

-(void)setHeader:(FMRefresh *)header
{
    if(![self isKindOfClass:[UITableView class]])
        return;
    
    if(self.header != header)
    {
        [self.header removeFromSuperview];
        
        switch (header.refreshType) {
            case FMRefresh_Default_Type:
            {
                [self insertSubview:header atIndex:0];
            }
                break;
            case FMRefresh_Backgroud_Type:
            {
                UITableView *tableView = (UITableView*)self;
                if(!tableView.backgroundView)
                {
                    tableView.backgroundView = [[UIView alloc]init];
                }
                
                [tableView.backgroundView addSubview:header];
            }
                break;
        }
        
        objc_setAssociatedObject(self, &key, header, OBJC_ASSOCIATION_ASSIGN);
    }
}

-(FMRefresh *)header
{
   return objc_getAssociatedObject(self, &key);
}

@end
