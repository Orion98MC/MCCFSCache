//
//  MCCNamedCache.m
//  MCCViewDemo
//
//  Created by Thierry Passeron on 10/09/12.
//  Copyright (c) 2012 Monte-Carlo Computing. All rights reserved.
//

#import "MCCFSCache.h"

@interface MCCFSCache ()
@property (retain, nonatomic) NSString *baseDir;
@end

@implementation MCCFSCache
@synthesize onSet, onGet, baseDir;

static NSMutableDictionary *_caches = nil;
static NSString *_cachesDir = nil;

+ (id)cacheNamed:(NSString*)name {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    // Caching will be done in the caches directory of the bundle
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    _cachesDir = [[paths objectAtIndex:0]retain];
    NSAssert(_cachesDir, @"Could not find caches directory");
    _caches = [[NSMutableDictionary alloc]init];
  });
  
  MCCFSCache *nc = [_caches objectForKey:name];
  if (!nc) {
    nc = [[[self alloc]init]autorelease];
    
    nc.onGet = ^id(NSString *fullPath) {
      return [[NSFileManager defaultManager] contentsAtPath:fullPath];
    };
    
    nc.onSet = ^id(id data, NSString *fullPath) {
      NSAssert([data isKindOfClass:[NSData class]], @"Default onSet expects NSData *");
      [[NSFileManager defaultManager]createFileAtPath:fullPath contents:data attributes:nil];
      return data;
    };
    
    nc.baseDir = [_cachesDir stringByAppendingPathComponent:name];
    
    // Create the baseDir
    NSError *error = nil;
    BOOL isDirectory = FALSE;
    BOOL exists = [[NSFileManager defaultManager]fileExistsAtPath:nc.baseDir isDirectory:&isDirectory];
    if (exists && !isDirectory) [NSException raise:@"MCCFSCache" format:@"%@ exists but is not a directory", nc.baseDir];
    
    if (!exists) {
      [[NSFileManager defaultManager]createDirectoryAtPath:nc.baseDir withIntermediateDirectories:YES attributes:nil error:&error];
      if (error) [NSException raise:@"MCCFSCache" format:@"Cannot create baseDir: Error: %@", error.description];
    }
    
    [_caches setObject:nc forKey:name];
  }
  return nc;
}

- (void)dealloc {
  self.onSet = nil;
  self.onGet = nil;
  self.baseDir = nil;
  [super dealloc];
}

+ (NSError *)removeCacheNamed:(NSString *)name {
  MCCFSCache *nc = [self cacheNamed:name];
  if (!nc || !nc.baseDir) return nil;
  
  NSError *error = nil;
  [[NSFileManager defaultManager]removeItemAtPath:nc.baseDir error:&error];
  if (!error) {
    [_caches removeObjectForKey:name];
  }
  
  return error;
}

+ (NSError *)clearCacheNamed:(NSString *)name {
  MCCFSCache *nc = [self cacheNamed:name];
  if (!nc || !nc.baseDir) return nil;
  NSFileManager *defaultManager = [NSFileManager defaultManager];
  
  BOOL isDirectory = FALSE;
  BOOL exists = [defaultManager fileExistsAtPath:nc.baseDir isDirectory:&isDirectory];
  if (!exists || !isDirectory) return nil;
  
  NSDirectoryEnumerator* en = [defaultManager enumeratorAtPath:nc.baseDir];

  NSError* error = nil;
  BOOL success;
  
  NSString* file;
  while (file = [en nextObject]) {
    success = [defaultManager removeItemAtPath:[nc.baseDir stringByAppendingPathComponent:file] error:&error];
    if (!success) { NSLog(@"Failed to remove cached file: %@", error); }
  }
  return error;
}

#define FULL_PATH(X) [baseDir stringByAppendingPathComponent:X]

- (id)setObject:(id)object forPath:(NSString *)relPath {
  NSAssert(baseDir, @"No base directory set");
  return onSet(object, FULL_PATH(relPath));
}

- (NSError *)removeObjectForPath:(NSString *)relPath {
  NSAssert(baseDir, @"No base directory set");
  NSError *error = nil;
  [[NSFileManager defaultManager]removeItemAtPath:FULL_PATH(relPath) error:&error];
  return error;
}

- (id)objectForPath:(NSString *)relPath {
  NSAssert(baseDir, @"No base directory set");  
  return onGet(FULL_PATH(relPath));
}

- (NSString *)fullPath:(NSString *)relPath {
  return FULL_PATH(relPath);
}

@end
