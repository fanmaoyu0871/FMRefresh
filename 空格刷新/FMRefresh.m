//
//  FMRefresh.m
//  空格refresh
//
//  Created by 范茂羽 on 16/1/6.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import "FMRefresh.h"
#import "UIView+Tools.h"

#define FMRefreshHeight 64.0f

@interface FMRefresh ()
{
    CGFloat _flixableHeight; //根据offsetY拉伸图片高度
    CGFloat _oriImageHeight; //imageView初始高度
    CGFloat _curOffsetY;     //当前offsetY
    
    BOOL isLoading;          //是否正在刷新标志
}

@property (nonatomic, weak)UITableView *tableView;      //父视图

@property (nonatomic, assign)UIEdgeInsets oriInsets;   //tableView初始insets

@property (nonatomic, copy)void (^refreshingBlock)();  //刷新block

@property (nonatomic, assign)FMRefreshState state;     //当前刷新控件状态

@property (nonatomic, strong)UIImageView *imageView;   //图片

@property (nonatomic, strong)NSMutableArray *animImages;//动画图片数组

@end

@implementation FMRefresh

-(NSMutableArray *)animImages
{
    if(!_animImages)
    {
        _animImages = [NSMutableArray array];
        
        for(NSInteger i = 1; i <= 7; i++)
        {
            NSString *path = [NSString stringWithFormat:@"MDPullLoading%ld", i];
            UIImage *image = [UIImage imageNamed:path];
            [_animImages addObject:image];
        }
    }
    
    return _animImages;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.imageView = [[UIImageView alloc]initWithFrame:frame];
        self.imageView.contentMode =UIViewContentModeScaleToFill;
        self.imageView.image = [UIImage imageNamed:@"MDPullEmoji"];
        [self.imageView sizeToFit];
        _oriImageHeight = self.imageView.height;
        self.imageView.animationImages = self.animImages;
        self.imageView.animationDuration = 0.5f;
        self.imageView.animationRepeatCount = INFINITY;
        [self addSubview:self.imageView];
    }
    
    return self;
}

+(instancetype)headerWithRefreshingBlock:(void (^)())block type:(FMRefreshType)type
{
    
    FMRefresh *refresh = [[FMRefresh alloc]init];
    refresh.refreshingBlock = block;
    refresh.refreshType = type;
    [refresh setState:FMRefreshStateNormal];
    return refresh;
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    NSAssert(newSuperview != nil, @"superView is nil");
    
    switch (self.refreshType) {
        case FMRefresh_Default_Type:
        {
            self.tableView = (UITableView*)newSuperview;
        }
            break;
        case FMRefresh_Backgroud_Type:
        {
            NSLog(@"%@", newSuperview.superview);
            self.tableView = (UITableView*)newSuperview.superview;
        }
            break;
    }
    
    self.oriInsets = self.tableView.contentInset;
    
    self.frame = CGRectMake(0, -FMRefreshHeight, self.tableView.width, FMRefreshHeight);
    self.imageView.center = CGPointMake(self.width/2, 0);
    self.imageView.y = 0;
    
//    [self.tableView removeObserver:self forKeyPath:@"contentOffset"]; //why crash
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"contentOffset"])
    {
        CGFloat y = [change[@"new"] CGPointValue].y;
        
        _curOffsetY = -self.oriInsets.top - y;
        
        if(_curOffsetY <= 0)
            return;
        
        if(self.tableView.isDragging)
        {
            if(_curOffsetY < FMRefreshHeight)
            {
                [self setState:FMRefreshStateNormal];
            }
            else if (_curOffsetY >= FMRefreshHeight)
            {
                _flixableHeight = _curOffsetY;
                NSLog(@"_flixableHeight = %f", _flixableHeight);
                [self setState:FMRefreshStatePulling];
            }
        }
        else
        {
            if(_curOffsetY >= FMRefreshHeight && self.state == FMRefreshStatePulling)
            {
                [self setState:FMRefreshStateRefreshing];
            }
            else if (_curOffsetY < FMRefreshHeight)
            {
                [self setState:FMRefreshStateNormal];
            }
        }
    }
}

-(void)setState:(FMRefreshState)state
{
    switch (state) {
        case FMRefreshStateNormal:
        {
            if(!isLoading)
            {
                [UIView animateWithDuration:0.25f animations:^{
                    self.tableView.contentInset = self.oriInsets;
                }];
            }
            self.y = -FMRefreshHeight + _curOffsetY;
            self.imageView.height = _oriImageHeight;
        }
            break;
        case FMRefreshStatePulling:
        {
            self.y = 0;
            UIEdgeInsets insets = UIEdgeInsetsMake(55, 0, 7, 0);
            self.imageView.image= [self.imageView.image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
            if(!isLoading)
            {
                self.imageView.height = _flixableHeight;
            }
        }
            break;
        case FMRefreshStateRefreshing:
        {
            isLoading = YES;
            [UIView animateWithDuration:0.15f animations:^{
                self.y = 0;
                UIEdgeInsets tmpInsets = self.oriInsets;
                tmpInsets.top += FMRefreshHeight;
                self.tableView.contentInset = tmpInsets;
                self.imageView.height = _oriImageHeight;
            } completion:^(BOOL finished) {
                [self.imageView startAnimating];
                
                if(self.refreshingBlock)
                {
                    self.refreshingBlock();
                }
            }];
        }
            break;
    }
    
    _state = state;
}

-(void)beginRefreshing
{
    [self setState:FMRefreshStateRefreshing];
}

-(void)endRefreshing
{
    isLoading = NO;
    [self.imageView stopAnimating];
    [self setState:FMRefreshStateNormal];
}



@end
