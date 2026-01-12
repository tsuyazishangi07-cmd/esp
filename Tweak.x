#import <UIKit/UIKit.h>

static UIButton *menuButton;
static UIView *testBox;

%ctor {
    // 15秒待つ（念には念を入れて、ゲームが完全に立ち上がるのを待つじょ！）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // --- 最新のiOSでも落ちない画面の取得方法 ---
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    window = ((UIWindowScene*)scene).windows.firstObject;
                    break;
                }
            }
        } else {
            window = [UIApplication sharedApplication].keyWindow;
        }

        if (!window) return; 

        // --- 1. テスト用の青い枠 ---
        testBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
        testBox.center = window.center;
        testBox.layer.borderColor = [UIColor cyanColor].CGColor;
        testBox.layer.borderWidth = 4.0;
        testBox.hidden = YES;
        testBox.userInteractionEnabled = NO; // タップを邪魔しない
        [window addSubview:testBox];

        // --- 2. スイッチボタン ---
        menuButton = [UIButton buttonWithType:UIButtonTypeSystem];
        menuButton.frame = CGRectMake(80, 80, 130, 50);
        [menuButton setTitle:@"ESP: OFF" forState:UIControlStateNormal];
        [menuButton setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.8]]; // 少し透明な赤
        [menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        menuButton.layer.cornerRadius = 10; // 角を丸くしてカッコよく！
        
        [menuButton addTarget:window action:@selector(handleEspToggle) forControlEvents:UIControlEventTouchUpInside];
        
        [window addSubview:menuButton];
        
        NSLog(@"[ESP] Safe System Loaded!");
    });
}

%hook UIWindow
%new
- (void)handleEspToggle {
    if (testBox.hidden) {
        testBox.hidden = NO;
        [menuButton setTitle:@"ESP: ON" forState:UIControlStateNormal];
        [menuButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:0.8]]; // 緑
    } else {
        testBox.hidden = YES;
        [menuButton setTitle:@"ESP: OFF" forState:UIControlStateNormal];
        [menuButton setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.8]]; // 赤
    }
}
%end
