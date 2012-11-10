#import <Foundation/Foundation.h>

@class PluginRegistry;

@protocol RegisteredPlugin <NSObject>

- (id)pluginRegistry:(PluginRegistry *)registry
                call:(NSString *)method
            withArgs:(NSDictionary *)args;

@end
