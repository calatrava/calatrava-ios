#import <Foundation/Foundation.h>
#import "JsRuntime.h"

@interface KernelBridge : NSObject
{
  id<JsRuntime> jsRt;
}

+ (KernelBridge *)sharedKernel;

- (void)startWith:(UINavigationController *)root;
- (void)launch:(NSString *)flow;

@end
