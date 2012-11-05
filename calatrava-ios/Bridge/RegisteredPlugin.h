#import <Foundation/Foundation.h>

@protocol RegisteredPlugin <NSObject>

- (id)call:(NSString *)method withArgs:(NSDictionary *)args;

@end
