#import <UIKit/UIKit.h>

// --- 安全第一！10秒待ってから動くコード ---

static UIButton *menuButton;
static UIView *testBox;

%ctor {
    // ゲーム起動時にここが呼ばれるけど、すぐには何もしない！
    // 10秒間（10 * NSEC_PER_SEC）じっと待つじょ
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 10秒経ったら、今の画面（Window）を取得する
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window) return; // もし画面が取得できなかったら何もしない（これでクラッシュ回避！）

        // --- ここからボタン作成 ---
        
        // 1. ESP動作確認用の箱（最初は隠す）
        testBox = [[UIView alloc] initWithFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width/2 - 50, UIScreen.mainScreen.bounds.size.height/2 - 50, 100, 100)];
        testBox.layer.borderColor = [UIColor cyanColor].CGColor;
        testBox.layer.borderWidth = 3.0;
        testBox.hidden = YES;
        [window addSubview:testBox];

        // 2. 左上のスイッチボタン
        menuButton = [UIButton buttonWithType:UIButtonTypeSystem];
        menuButton.frame = CGRectMake(100, 50, 120, 45); // ちょっと場所をずらしたじょ
        [menuButton setTitle:@"ESP: OFF" forState:UIControlStateNormal];
        [menuButton setBackgroundColor:[UIColor redColor]];
        [menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        // ボタンを押した時の動作（Tweakだとこれが一番安全な書き方だじょ）
        [menuButton addTarget:window action:@selector(handleEspToggle) forControlEvents:UIControlEventTouchUpInside];
        
        [window addSubview:menuButton];
        
        // 成功したらログを出す
        NSLog(@"[ESP] Safe Load Success!");
    });
}

// ボタンの処理をUIWindowに追加する魔法
%hook UIWindow
%new
- (void)handleEspToggle {
    // ここで変数を操作
    if (testBox.hidden) {
        testBox.hidden = NO;
        [menuButton setTitle:@"ESP: ON" forState:UIControlStateNormal];
        [menuButton setBackgroundColor:[UIColor greenColor]];
    } else {
        testBox.hidden = YES;
        [menuButton setTitle:@"ESP: OFF" forState:UIControlStateNormal];
        [menuButton setBackgroundColor:[UIColor redColor]];
    }
}
%end
