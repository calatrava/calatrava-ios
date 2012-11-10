#import "PluginRegistry.h"

@implementation PluginRegistry

- (id)init
{
  self = [super init];
  if (self)
  {
    registeredPlugins = [[NSMutableDictionary alloc] initWithCapacity:5];
  }
  return self;
}

- (id)attachToRuntime:(id<JsRuntime>)rt
{
  runtime = rt;
  [rt setPluginDelegate:self];
}

- (id) registerPlugin:(NSObject<RegisteredPlugin> *)plugin
                named:(NSString *)name
{
  [registeredPlugins setObject:plugin forKey:name];
  return self;
}

- (id)callPlugin:(NSString *)plugin
          method:(NSString *)method
        withArgs:(NSDictionary *)args
{
  [(NSObject<RegisteredPlugin> *)[registeredPlugins objectForKey:plugin] pluginRegistry:self
                                                                                   call:method
                                                                               withArgs:args];
  return self;
}

- (id)invokeCallback:(NSString *)handle with:(id)data
{
  [runtime callJsFunction:@"calatrava.inbound.invokePluginCallback"
                 withArgs:@[handle, data]];
}

@end
