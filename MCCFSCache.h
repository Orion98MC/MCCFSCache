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
@property (assign, nonatomic) dispatch_queue_t queue;

+ (id)cacheNamed:(NSString*)name;
+ (NSError *)removeCacheNamed:(NSString *)name;
+ (NSError *)clearCacheNamed:(NSString *)name;

- (void)setObject:(id)object forPath:(NSString *)relPath callback:(void(^)(id))callback;
- (void)removeObjectForPath:(NSString *)relPath callback:(void(^)(id))callback;
- (void)objectForPath:(NSString *)relPath callback:(void(^)(id))callback;

- (NSString *)fullPath:(NSString *)relPath;

@end
