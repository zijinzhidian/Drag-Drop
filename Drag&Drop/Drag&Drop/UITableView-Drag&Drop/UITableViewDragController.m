//
//  UITableViewDragController.m
//  Drag&Drop
//
//  Created by apple on 2018/1/15.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "UITableViewDragController.h"
#import "DragImageCell.h"

static NSString *const identifier = @"identifier";

@interface UITableViewDragController ()<UITableViewDelegate,UITableViewDataSource,UITableViewDragDelegate,UITableViewDropDelegate>

@property(nonatomic,strong)UITableView *tableView;

@property(nonatomic,strong)NSMutableArray *dataArray;

@property(nonatomic,strong)NSIndexPath *dragIndexPath;

@end

@implementation UITableViewDragController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DragImageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.targetImageView.image = self.dataArray[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView shouldSpringLoadRowAtIndexPath:(NSIndexPath *)indexPath withContext:(id<UISpringLoadedInteractionContext>)context {
    
    return YES;
}


#pragma mark - UITableViewDragDelegate
- (nonnull NSArray<UIDragItem *> *)tableView:(nonnull UITableView *)tableView itemsForBeginningDragSession:(nonnull id<UIDragSession>)session atIndexPath:(nonnull NSIndexPath *)indexPath {
    
    NSItemProvider *provider = [[NSItemProvider alloc] initWithObject:self.dataArray[indexPath.row]];
    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:provider];
    self.dragIndexPath = indexPath;
    return @[item];
    
}

//- (NSArray<UIDragItem *> *)tableView:(UITableView *)tableView itemsForAddingToDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point {
//
//    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:self.dataArray[indexPath.row]];
//    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
//    return @[item];
//}

//预览视图参数
- (nullable UIDragPreviewParameters *)tableView:(UITableView *)tableView dragPreviewParametersForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIDragPreviewParameters *parameters = [[UIDragPreviewParameters alloc] init];
    parameters.visiblePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, tableView.bounds.size.width, tableView.rowHeight) cornerRadius:10];
    return parameters;
}

#pragma mark - UITableViewDropDelegate
- (void)tableView:(UITableView *)tableView performDropWithCoordinator:(id<UITableViewDropCoordinator>)coordinator {
    
    NSIndexPath *destinationIndexPath = coordinator.destinationIndexPath;
    
    if (self.dragIndexPath.section == destinationIndexPath.section && self.dragIndexPath.row == destinationIndexPath.row) {
        return;
    }
    
    [tableView performBatchUpdates:^{
        
        id obj = self.dataArray[self.dragIndexPath.row];
        [self.dataArray removeObjectAtIndex:self.dragIndexPath.row];
        [self.dataArray insertObject:obj atIndex:destinationIndexPath.row];
        [tableView deleteRowsAtIndexPaths:@[self.dragIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView insertRowsAtIndexPaths:@[destinationIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } completion:nil];
    
}

// 该方法是提供释放方案的方法，虽然是optional，但是最好实现
// 当 跟踪 drop 行为在 tableView 空间坐标区域内部时会频繁调用
// 当drop手势在某个section末端的时候，传递的目标索引路径还不存在（此时 indexPath 等于 该 section 的行数），这时候会追加到该section 的末尾
// 在某些情况下，目标索引路径可能为空（比如拖到一个没有cell的空白区域）
// 请注意，在某些情况下，你的建议可能不被系统所允许，此时系统将执行不同的建议
// 你可以通过 -[session locationInView:] 做你自己的命中测试
- (UITableViewDropProposal *)tableView:(UITableView *)tableView dropSessionDidUpdate:(id<UIDropSession>)session withDestinationIndexPath:(nullable NSIndexPath *)destinationIndexPath {
    
    /**
     // TableView将会接受drop，但是具体的位置还要稍后才能确定T
     // 不会打开一个缺口，也许你可以提供一些视觉上的处理来给用户传达这一信息
     UITableViewDropIntentUnspecified,
     
     // drop 将会插入到目标索引路径
     // 将会打开一个缺口,模拟最后释放后的布局
     UITableViewDropIntentInsertAtDestinationIndexPath,
     
     drop 将会释放在目标索引路径，比如该cell是一个容器（集合），此时不会像 👆 那个属性一样打开缺口，但是该条目标索引对应的cell会高亮显示
     UITableViewDropIntentInsertIntoDestinationIndexPath,
     
     tableView 会根据dro 手势的位置在 .insertAtDestinationIndexPath 和 .insertIntoDestinationIndexPath 自动选择，
     UITableViewDropIntentAutomatic
     */
    UITableViewDropProposal *dropProposal;
    // 如果是另外一个app，localDragSession为nil，此时就要执行copy，通过这个属性判断是否是在当前app中释放，当然只有 iPad 才需要这个适配
    if (session.localDragSession) {
        dropProposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationMove intent:UITableViewDropIntentInsertAtDestinationIndexPath];
    } else {
        dropProposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationCopy intent:UITableViewDropIntentInsertAtDestinationIndexPath];
    }
    
    return dropProposal;
}

#pragma mark - Getters And Setters
- (UITableView *)tableView {
    if (_tableView == nil) {
        
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.dragDelegate = self;
        _tableView.dropDelegate = self;
        _tableView.dragInteractionEnabled = YES;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.rowHeight = 250;
        [_tableView registerNib:[UINib nibWithNibName:@"DragImageCell" bundle:nil] forCellReuseIdentifier:identifier];
        
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        
        _dataArray = @[].mutableCopy;
        for (int i = 0; i < 5; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",i + 1]];
            [_dataArray addObject:image];
        }
        
    }
    return _dataArray;
}

@end
