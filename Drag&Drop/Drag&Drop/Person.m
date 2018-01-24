//
//  Person.m
//  Drag&Drop
//
//  Created by apple on 2018/1/15.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "Person.h"

@implementation Person

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        
        self.name = [coder decodeObjectForKey:@"name"];
        self.age = [coder decodeIntegerForKey:@"age"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeInteger:self.age forKey:@"age"];
}

- (nullable NSProgress *)loadDataWithTypeIdentifier:(NSString *)typeIdentifier
                   forItemProviderCompletionHandler:(void (^)(NSData * _Nullable data, NSError * _Nullable error))completionHandler {
    NSProgress *progress = [[NSProgress alloc] init];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    completionHandler(data,nil);
    return progress;
}

+(NSItemProviderRepresentationVisibility)itemProviderVisibilityForRepresentationWithTypeIdentifier:(NSString *)typeIdentifier{
    return NSItemProviderRepresentationVisibilityAll;
}

- (NSItemProviderRepresentationVisibility)itemProviderVisibilityForRepresentationWithTypeIdentifier:(NSString *)typeIdentifier{
    return NSItemProviderRepresentationVisibilityAll;
}

//提供一个标识符
+(NSArray<NSString *> *)writableTypeIdentifiersForItemProvider{
    return @[@"object"];
}

//这两个是读协议
+(NSArray<NSString *> *)readableTypeIdentifiersForItemProvider{
    return @[@"object"];
}
//解归档返回
+ (nullable instancetype)objectWithItemProviderData:(NSData *)data
                                     typeIdentifier:(NSString *)typeIdentifier
                                              error:(NSError **)outError{
    Person * p = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return p;
}

@end
