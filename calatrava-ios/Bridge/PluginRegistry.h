#import <Foundation/Foundation.h>

#import "JsRuntime.h"
#import "RegisteredPlugin.h"

@interface PluginRegistry : NSObject<JsRtPluginDelegate>
{
  NSMutableDictionary *registeredPlugins;
}

+ (PluginRegistry *)sharedRegistry;

- (id) registerPlugin:(NSObject<RegisteredPlugin> *)plugin
                named:(NSString *)name;

@end
