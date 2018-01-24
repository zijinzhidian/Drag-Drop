//
//  ViewController.m
//  Drag&Drop
//
//  Created by apple on 2018/1/12.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

static NSString *const kIdentifier = @"cellIdentifier";

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSArray *titleNameArray;
@property(nonatomic,strong)NSArray *controllerNameArray;

@end

@implementation ViewController

#pragma mark - Initialize
- (void)defalutInitialize {
    self.titleNameArray = @[@[@"UIView-Drag&Drop",@"UITableView-Drag&Drop"]];
    self.controllerNameArray = @[@[@"UIViewDragController",@"UITableViewDragController"]];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self defalutInitialize];
    
    [self setupNavigationBar];
    
    [self.view addSubview:self.tableView];
    
}

#pragma mark - Private Method
/**
 设置导航栏
 */
- (void)setupNavigationBar {
    
    //导航栏标题
    self.title = @"Drag&Drop";
    //开启大标题效果
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
}

//判断对象是否存在该属性
- (BOOL)checkIsExistPropertyWithInstance:(id)instance verifyPropertyName:(NSString *)verifyPropertyName {
    
    unsigned int outCount, i;
    //获取对象里的属性列表
    objc_property_t * properties = class_copyPropertyList([instance class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property =properties[i];
        //属性名转成字符串
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        //判断该属性是否存在
        if ([propertyName isEqualToString:verifyPropertyName]) {
            free(properties);
            return YES;
        }
    }
    free(properties);
    
    //再遍历父类中的属性
    Class superClass = class_getSuperclass([instance class]);
    //通过下面的方法获取属性列表
    unsigned int outCount2;
    objc_property_t *properties2 = class_copyPropertyList(superClass, &outCount2);
    
    for (int i = 0 ; i < outCount2; i++) {
        objc_property_t property2 = properties2[i];
        //属性名转成字符串
        NSString *propertyName2 = [[NSString alloc] initWithCString:property_getName(property2) encoding:NSUTF8StringEncoding];
        //判断该属性是否存在
        if ([propertyName2 isEqualToString:verifyPropertyName]) {
            free(properties2);
            return YES;
        }
    }
    free(properties2); //释放数组
    
    return NO;
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 2;
    } else {
        return 2;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.titleNameArray[indexPath.section][indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //类名
    const char *className = [self.controllerNameArray[indexPath.section][indexPath.row] UTF8String];
    Class class = objc_getClass(className);

    if (class == nil) {
        //创建一个父类
        Class superClass = [NSObject class];
        //创建需要的类
        class = objc_allocateClassPair(superClass, className, 0);
        //注册
        objc_registerClassPair(class);
    }
    //创建对象
    id instance = [[class alloc] init];
    //赋值
    if ([self checkIsExistPropertyWithInstance:instance verifyPropertyName:@"titleName"]) {
        //KVC赋值
        [instance setValue:self.titleNameArray[indexPath.section][indexPath.row] forKey:@"titleName"];
    }

    [self.navigationController pushViewController:instance animated:YES];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"iOS11 新特征";
    } else {
        return @"iOS10.3 新特征";
    }
}

#pragma mark - Getters And Setters
- (UITableView *)tableView {
    if (_tableView == nil) {
        
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 60;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kIdentifier];
        
    }
    return _tableView;
}


@end
