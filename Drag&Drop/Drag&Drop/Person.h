//
//  Person.h
//  Drag&Drop
//
//  Created by apple on 2018/1/15.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>

//遵守协议
@interface Person : NSObject<NSItemProviderWriting,NSItemProviderReading>

//自定义内容
@property(nonatomic,strong)NSString *name;
@property(nonatomic,assign)NSInteger age;

@end
