## Description

MCCFSCache helps you store and retrieve data to or from the caches directory of your application's bundle. (iOS4+)

MCCFSCache is data agnostic and thus lets you define set and get blocks to retrieve or save data to disk.

MCCFSCache may be used from dispatch queues but the definition of caches should be done on the main thread.

## Example

Create a cache for downloaded thumbnails in your Application delegate - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions :

```objective-c
CGFloat scale = [[UIScreen mainScreen]scale];
  
MCCFSCache *cache = [MCCFSCache cacheNamed:@"thumbnails"];

cache.onSet = ^UIImage*(UIImage *image, NSString *fullPath) {
  UIImage *resized = resizeImageToSize(image, (CGSize){80.0 * scale, 60.0 * scale});
  if (!resized) return nil;
    
  NSString *realPath = nameWithScaleOfImageAtPath(fullPath, scale); // Sets a @2x if needed
  [UIImageJPEGRepresentation(resized, 0.8) writeToFile:realPath atomically:YES];
  return [UIImage imageWithContentsOfFile:realPath];
};
  
cache.onGet = ^id(NSString *fullPath) {
  NSString *realPath = nameWithScaleOfImageAtPath(fullPath, scale); // Gets the @2x if needed
  if (![[NSFileManager defaultManager] fileExistsAtPath:realPath]) return nil;
  return [UIImage imageWithContentsOfFile:realPath];
};
```

Then anywhere in your applications' code:
```objective-c
UIImage *image = [[MCCFSCache cacheNamed:@"thumbnails"]objectForPath:imageName];
```


## License terms

Copyright (c), 2012 Thierry Passeron

The MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.