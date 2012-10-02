#import "KernelBridge.h"
#import "WebRuntime.h"
#include "TWBridgePageRegistry.h"
#include "TWBridgeURLRequestManager.h"

static KernelBridge *kernel = nil;

@implementation KernelBridge

+ (KernelBridge *)sharedKernel
{
  if (kernel == nil)
  {
    kernel = [[KernelBridge alloc] init];
  }
  return kernel;
}

- (id)init
{
  if (self = [super init])
  {
    //    jsRt = [[EmbeddedRuntime alloc] init];
    jsRt = [[WebRuntime alloc] init];
  }
  return self;
}

- (void)startWith:(UINavigationController *)root
{
  NSString *bundle = [[NSBundle mainBundle] bundlePath];
  
  // Load js libraries
  [jsRt loadJsFile:[NSString stringWithFormat:@"%@/public/assets/scripts/underscore.js", bundle]];
  
  // Load js bridge
  [jsRt loadJsFile:[NSString stringWithFormat:@"%@/public/assets/scripts/env.js", bundle]];
  [jsRt loadJsFile:[NSString stringWithFormat:@"%@/public/assets/scripts/calatrava.js", bundle]];
  NSString *loadFileText = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/public/assets/load_file.text", bundle]
                                                     encoding:NSASCIIStringEncoding
                                                        error:nil];
  NSArray *jsFiles = [loadFileText componentsSeparatedByString:@"\n"];
  for (NSString *jsFile in jsFiles) {
    if ([jsFile length] != 0)
    {
      [jsRt loadJsFile:[NSString stringWithFormat:jsFile, bundle]];
    }
  }
  
  [[TWBridgePageRegistry sharedRegistry] attachToRuntime:jsRt under:root];
  [[TWBridgeURLRequestManager sharedManager] attachToRuntime:jsRt under:root];
}

- (void)launch:(NSString *)flow
{
  [jsRt callJsFunction:flow withArgs:nil];
}

@end
