#import "AlertPlugin.h"
#import <UIKit/UIKit.h>

#import "PluginRegistry.h"

@implementation AlertPlugin

- (id)pluginRegistry:(PluginRegistry *)registry
                call:(NSString *)method
            withArgs:(NSDictionary *)args
{
  id delegate = nil;
  NSString *cancelTitle = nil;
  
  if ([method isEqualToString:@"displayConfirm"])
  {
    delegate = self;
    cancelTitle = @"Cancel";
    currentOkCallbackHandle = [args objectForKey:@"okHandler"];
    self->registry = registry;
  }
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                  message:[args objectForKey:@"message"]
                                                 delegate:delegate
                                        cancelButtonTitle:cancelTitle
                                        otherButtonTitles:@"OK", nil];
  [alert show];
  return self;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  [registry invokeCallback:currentOkCallbackHandle
                      with:[NSNumber numberWithInteger:buttonIndex]];
}

@end
