#import <Foundation/Foundation.h>
#import "JsRuntime.h"

#import <UIKit/UIKit.h>

@interface WebRuntime : NSObject<JsRuntime, UIWebViewDelegate>
{
  UIWebView *rtWebView;
  BOOL isLoadingHtml;
  int outstandingScriptLoads;
  NSMutableArray *filesToLoad;
  NSMutableArray *functionsToCall;
  
  id<JsRtPageDelegate> pageDelegate;
  id<JsRtTimerDelegate> timerDelegate;
  id<JsRtRequestDelegate> requestDelegate;
}

@property (nonatomic, retain) id<JsRtPageDelegate> pageDelegate;
@property (nonatomic, retain) id<JsRtTimerDelegate> timerDelegate;
@property (nonatomic, retain) id<JsRtRequestDelegate> requestDelegate;
@property (nonatomic, retain) id<JsRtUiDelegate> uiDelegate;

- (id)init;

@end
