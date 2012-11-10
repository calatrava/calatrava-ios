#import <Foundation/Foundation.h>

#import "JsRuntime.h"
#import "RegisteredPlugin.h"

@interface PluginRegistry : NSObject<JsRtPluginDelegate>
{
  id<JsRuntime> runtime;
  NSMutableDictionary *registeredPlugins;
}

- (id)attachToRuntime:(id<JsRuntime>)rt;

- (id) registerPlugin:(NSObject<RegisteredPlugin> *)plugin
                named:(NSString *)name;
- (id)invokeCallback:(NSString *)handle with:(id)data;

@end
