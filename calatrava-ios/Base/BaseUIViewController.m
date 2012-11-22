#import "BaseUIViewController.h"
#import "TWBridgePageRegistry.h"

@implementation BaseUIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        handlers = [NSMutableDictionary dictionaryWithCapacity:5];
    }
  
    return self;
}

- (id)attachHandler:(NSString *)proxyId forEvent:(NSString *)event
{
    [handlers setValue:proxyId forKey:event];
    return self;
}

- (id)dispatchEvent:(NSString *)event withArgs:(NSArray *)args
{
  NSString *proxyId = [handlers objectForKey:event];
  if (proxyId) {
    [[TWBridgePageRegistry sharedRegistry] dispatchEvent:event fromProxy:proxyId withArgs:args];
  }
  return self;
}

- (void) scrollToTop{
  // Noop default implemenatation. Feel free to override in your derived class.
}


- (id)valueForField:(NSString *)field{
  // default implementation.
  return nil;
}

- (void)render:(NSDictionary *)viewMessage{
  // Noop default implementation. Override in your derived class.
}

- (void)displayDialog:(NSString *)message{
  // Noop default implementation. Override in your derived class.
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
	
  [[TWBridgePageRegistry sharedRegistry] setCurrentPage:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
