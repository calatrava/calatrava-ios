#import "PluginRegistry.h"

static PluginRegistry *plugin_instance = nil;

@implementation PluginRegistry

+ (PluginRegistry *)sharedRegistry
{
  if (!plugin_instance)
  {
    plugin_instance = [[PluginRegistry alloc] init];
  }
  return plugin_instance;
}

- (id)init
{
  self = [super init];
  if (self)
  {
    registeredPlugins = [[NSMutableDictionary alloc] initWithCapacity:5];
  }
  return self;
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
  [(NSObject<RegisteredPlugin> *)[registeredPlugins objectForKey:plugin] call:method
                                                                     withArgs:args];
  return self;
}

@end
