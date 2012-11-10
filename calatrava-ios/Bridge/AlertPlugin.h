#import <Foundation/Foundation.h>
#import "RegisteredPlugin.h"

@interface AlertPlugin : NSObject<RegisteredPlugin, UIAlertViewDelegate>
{
  id currentOkCallbackHandle;
  __weak PluginRegistry *registry;
}
@end
