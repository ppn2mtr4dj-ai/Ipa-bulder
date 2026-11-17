// App base (WebView) — abre www/<GBEntry> (definido pelo IPA Builder no Info.plist)
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface GBViewController : UIViewController <WKUIDelegate, WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *web;
@end

@implementation GBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    WKWebViewConfiguration *cfg = [[WKWebViewConfiguration alloc] init];
    cfg.allowsInlineMediaPlayback = YES;
    cfg.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;

    self.web = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:cfg];
    self.web.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.web.UIDelegate = self;
    self.web.navigationDelegate = self;
    self.web.opaque = NO;
    self.web.backgroundColor = [UIColor blackColor];
    self.web.scrollView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.web];

    NSString *entry = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"GBEntry"];
    if (![entry isKindOfClass:[NSString class]] || entry.length == 0) entry = @"index.html";

    NSURL *root = [[NSBundle mainBundle].bundleURL URLByAppendingPathComponent:@"www" isDirectory:YES];
    NSURL *file = [root URLByAppendingPathComponent:entry];

    if ([[NSFileManager defaultManager] fileExistsAtPath:file.path]) {
        [self.web loadFileURL:file allowingReadAccessToURL:root];
    } else {
        NSString *msg = [NSString stringWithFormat:
            @"<meta name='viewport' content='width=device-width,initial-scale=1'>"
            @"<body style='background:#000;color:#fff;font-family:-apple-system;padding:28px'>"
            @"<h2>Arquivo não encontrado</h2><p>www/%@</p></body>", entry];
        [self.web loadHTMLString:msg baseURL:nil];
    }
}

// alert() do JavaScript
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message
                                                         initiatedByFrame:(WKFrameInfo *)frame
                                                        completionHandler:(void (^)(void))completionHandler {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:nil message:message
                                                        preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *x) { completionHandler(); }]];
    [self presentViewController:a animated:YES completion:nil];
}

// confirm() do JavaScript
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message
                                                           initiatedByFrame:(WKFrameInfo *)frame
                                                          completionHandler:(void (^)(BOOL))completionHandler {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:nil message:message
                                                        preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel
                                        handler:^(UIAlertAction *x) { completionHandler(NO); }]];
    [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *x) { completionHandler(YES); }]];
    [self presentViewController:a animated:YES completion:nil];
}

// links com target="_blank" abrem na mesma tela
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
                                                        forNavigationAction:(WKNavigationAction *)navigationAction
                                                             windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) [webView loadRequest:navigationAction.request];
    return nil;
}

@end


@interface GBAppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;
@end

@implementation GBAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[GBViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}
@end


int main(int argc, char *argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([GBAppDelegate class]));
    }
}
