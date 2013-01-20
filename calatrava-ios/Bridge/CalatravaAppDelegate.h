#import <Foundation/Foundation.h>
#import "AJAXConnection.h"

@protocol CalatravaAppDelegate <NSObject>

- (void)ajaxRequestStarted:(AJAXConnection *)request;
- (void)ajaxRequestCompleted:(AJAXConnection *)request;

@end
