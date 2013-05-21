#import <UIKit/UIKit.h>
#import "BaseUIViewController.h"

@interface WebViewController :  BaseUIViewController <UIWebViewDelegate>
{
  UIWebView *_webView;
  NSMutableOrderedSet *queuedBinds;
  NSMutableOrderedSet *queuedRenders;
  BOOL webViewReady;
}

- (id)initWithPageName:(NSString *)thePageName;
- (NSString *)pageName;

@end
