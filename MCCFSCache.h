//
//  MCCNamedCache.h
//  MCCViewDemo
//
//  Created by Thierry Passeron on 10/09/12.
//  Copyright (c) 2012 Monte-Carlo Computing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCCFSCache : NSObject

@property (copy, nonatomic) id(^onSet)(id data, NSString*fullPath);
@property (copy, nonatomic) id(^onGet)(NSString *fullPath);

+ (id)cacheNamed:(NSString*)name;
+ (NSError *)removeCacheNamed:(NSString *)name;

- (id)setObject:(id)object forPath:(NSString *)relPath;
- (NSError *)removeObjectForPath:(NSString *)relPath;
- (id)objectForPath:(NSString *)relPath;
- (NSString *)fullPath:(NSString *)relPath;

@end
