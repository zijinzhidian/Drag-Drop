//
//  UIViewDragController.m
//  Drag&Drop
//
//  Created by apple on 2018/1/12.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "UIViewDragController.h"

@interface UIViewDragController ()<UIDragInteractionDelegate,UIDropInteractionDelegate>

@property(nonatomic,strong)UIImageView *dragView1;
@property(nonatomic,strong)UIImageView *dragView2;

@end

@implementation UIViewDragController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.dragView1];
    [self.view addSubview:self.dragView2];
    
    [self addDragInteractionForView:self.dragView1];
    [self addDropInteractionForView:self.dragView2];
    
}

#pragma mark - Actions
//为视图添加可拖拽行为
- (void)addDragInteractionForView:(UIView *)view {
    
    UIDragInteraction *dragInteraction = [[UIDragInteraction alloc] initWithDelegate:self];
    //激活该行为
    dragInteraction.enabled = YES;
    //添加drag
    [view addInteraction:dragInteraction];
    
    
}

//为视图添加放置行为
- (void)addDropInteractionForView:(UIView *)view {
    
    UIDropInteraction *dropInteraction = [[UIDropInteraction alloc] initWithDelegate:self];
    //添加drop
    [view addInteraction:dropInteraction];
    
}

- (UIDragItem *)addDragItemForView:(id<NSItemProviderWriting>)object {
    
    //NSItemProvider供应者:用于提供数据
    NSItemProvider *provider = [[NSItemProvider alloc] initWithObject:object];
    //创建可拖拽的Item
    UIDragItem *dragItem = [[UIDragItem alloc] initWithItemProvider:provider];
    //设置要传递的额外信息,只有在同个App内可见
    dragItem.localObject = @"额外扩展信息";
 
    return dragItem;
    
}

#pragma mark - UIDragInteractionDelegate
//当用户长按目标会生成UIDragSession时调用(lift抬起状态),返回可供拖拽的item
- (NSArray<UIDragItem *> *)dragInteraction:(UIDragInteraction *)interaction itemsForBeginningSession:(id<UIDragSession>)session {
    
    return @[[self addDragItemForView:self.dragView1.image]];
    
}

/*
 1.处于lift状态时会有一个preview的预览功效,其抬起放大动画是系统自动生成的
 2.不实现该方法系统会默认给interaction.view生成一个预览视图UITargetedDragPreview
 3.可以实现该方法,返回自定义参数的预览视图
 4.有几个item就会执行几次
 */
- (nullable UITargetedDragPreview *)dragInteraction:(UIDragInteraction *)interaction previewForLiftingItem:(UIDragItem *)item session:(id<UIDragSession>)session {
    
    //预览视图参数
    UIDragPreviewParameters *parameters = [[UIDragPreviewParameters alloc] init];
    //可显示范围路径
    parameters.visiblePath = [UIBezierPath bezierPathWithRoundedRect:interaction.view.bounds cornerRadius:10];

    //为目标生成预览视图
    UITargetedDragPreview *preview = [[UITargetedDragPreview alloc] initWithView:interaction.view parameters:parameters];

    return preview;

}

//当取消拖拽时返回的预览视图,可以直接返回defaultPreview
- (nullable UITargetedDragPreview *)dragInteraction:(UIDragInteraction *)interaction previewForCancellingItem:(UIDragItem *)item withDefault:(UITargetedDragPreview *)defaultPreview {

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, interaction.view.bounds.size.width, interaction.view.bounds.size.height)];
    imageView.image = self.dragView1.image;

    UIDragPreviewTarget *previewTarget = [[UIDragPreviewTarget alloc] initWithContainer:interaction.view center:CGPointMake(interaction.view.bounds.size.width / 2, interaction.view.bounds.size.height / 2)];

    UITargetedDragPreview *dragPreview = [[UITargetedDragPreview alloc] initWithView:imageView parameters:[UIDragPreviewParameters new] target:previewTarget];

    return dragPreview;
    
//    return defaultPreview;
    
    
}

//当lift动画准备执行的时候调用该方法,animator为属性动画器,可以在该方法里添加动画
- (void)dragInteraction:(UIDragInteraction *)interaction willAnimateLiftWithAnimator:(id<UIDragAnimating>)animator session:(id<UIDragSession>)session {
    
    NSLog(@"lift动画将要开始");
    
    //当lift动画结束时调用该block
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        /*
         UIViewAnimatingPositionStart表示lift动画回到起点,即用户长按后松开未进行拖拽
         UIViewAnimatingPositionEnd表示lift动画结束,即用户开始拖拽
         */
        if (finalPosition == UIViewAnimatingPositionEnd) {
            self.dragView1.alpha = 0.5;
        }

    }];
}

//取消拖拽动画时调用(即拖拽后用户手指离开屏幕时调用,有几个item就会调用几次)
- (void)dragInteraction:(UIDragInteraction *)interaction item:(UIDragItem *)item willAnimateCancelWithAnimator:(id<UIDragAnimating>)animator {
   
    NSLog(@"手指离开屏幕");
    
    [animator addAnimations:^{
        
        self.dragView1.alpha = 1;
        
    }];
}

//当用户完成一次拖拽操作,并且所有相关的动画都执行完毕时调用
- (void)dragInteraction:(UIDragInteraction *)interaction session:(id<UIDragSession>)session didEndWithOperation:(UIDropOperation)operation {
    NSLog(@"所有动画结束");
}

#pragma mark - UIDropInteractionDelegate
//是否响应此次行为
- (BOOL)dropInteraction:(UIDropInteraction *)interaction canHandleSession:(id<UIDropSession>)session {
    //返回是否能加载该类的数据
    return [session canLoadObjectsOfClass:[UIImage class]];
}

//拖拽退出视图时调用
- (void)dropInteraction:(UIDropInteraction *)interaction sessionDidExit:(id<UIDropSession>)session {
    NSLog(@"退出");
}

//拖拽进入视图时调用
- (void)dropInteraction:(UIDropInteraction *)interaction sessionDidEnter:(id<UIDropSession>)session {
    NSLog(@"进入");
}

//拖拽进入视图且结束时调用(不管当前是enter还是exit都会调用)
- (void)dropInteraction:(UIDropInteraction *)interaction sessionDidEnd:(id<UIDropSession>)session {
    NSLog(@"结束");
}

//当拖拽视图、在视图范围内移动、添加拖拽到视图内时调用
- (UIDropProposal *)dropInteraction:(UIDropInteraction *)interaction sessionDidUpdate:(id<UIDropSession>)session {\
    
    //    UIDropOperation dropOperation = session.localDragSession ? UIDropOperationMove : UIDropOperationCopy;
    UIDropOperation dropOperation = UIDropOperationMove;
    UIDropProposal *dropProposal = [[UIDropProposal alloc] initWithDropOperation:dropOperation];
    
    return dropProposal;
    
}

//在视图内进行放置时调用,在session中获取被传递的数据
- (void)dropInteraction:(UIDropInteraction *)interaction performDrop:(id<UIDropSession>)session {
    
    for (UIDragItem *dragItem in session.items) {
        
        [dragItem.itemProvider loadObjectOfClass:[UIImage class] completionHandler:^(id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error) {
            UIImage *image = (UIImage *)object;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.dragView2.image = image;
            });
        }];
    }
}

- (UITargetedDragPreview *)dropInteraction:(UIDropInteraction *)interaction previewForDroppingItem:(UIDragItem *)item withDefault:(UITargetedDragPreview *)defaultPreview {
    NSLog(@"previewForDroppingItem");
    if (item.localObject) {
        CGPoint dropPoint = defaultPreview.view.center;
        UIDragPreviewTarget *previewTarget = [[UIDragPreviewTarget alloc] initWithContainer:self.dragView1 center:dropPoint];
        return [defaultPreview retargetedPreviewWithTarget:previewTarget];
    } else {
        return nil;
    }
}

#pragma mark - Getters And Setters
- (UIImageView *)dragView1 {
    if (_dragView1 == nil) {
        
        _dragView1 = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 290) / 2, 200, 290, 163)];
        _dragView1.image = [UIImage imageNamed:@"弄玉.jpg"];
        _dragView1.userInteractionEnabled = YES;
        
    }
    return _dragView1;
}

- (UIImageView *)dragView2 {
    if (_dragView2 == nil) {
        
        _dragView2 = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 290) / 2, 100 + 290 + 100, 290, 163)];
        _dragView2.image = [UIImage imageNamed:@"阿岚.jpg"];
        _dragView2.userInteractionEnabled = YES;
        
    }
    return _dragView2;
}



@end
