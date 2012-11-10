#import <Foundation/Foundation.h>
#import "JsRuntime.h"

@class PluginRegistry;

@interface KernelBridge : NSObject
{
  id<JsRuntime> jsRt;
  PluginRegistry *pluginRegistry;
}

+ (KernelBridge *)sharedKernel;

- (PluginRegistry *)pluginRegistry;

- (void)startWith:(UINavigationController *)root;
- (void)launch:(NSString *)flow;

@end
