#import "AlertPlugin.h"
#import <UIKit/UIKit.h>

@implementation AlertPlugin

- (id)call:(NSString *)method withArgs:(NSDictionary *)args
{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                  message:[args objectForKey:@"message"]
                                                 delegate:nil
                                        cancelButtonTitle:nil
                                        otherButtonTitles:@"OK", nil];
  [alert show];
  return self;
}

@end
