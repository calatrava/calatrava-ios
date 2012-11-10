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
  id<JsRtPluginDelegate> pluginDelegate;
}

@property (nonatomic, strong) id<JsRtPageDelegate> pageDelegate;
@property (nonatomic, strong) id<JsRtTimerDelegate> timerDelegate;
@property (nonatomic, strong) id<JsRtRequestDelegate> requestDelegate;
@property (nonatomic, strong) id<JsRtUiDelegate> uiDelegate;
@property (nonatomic, strong) id<JsRtPluginDelegate> pluginDelegate;

- (id)init;

@end
