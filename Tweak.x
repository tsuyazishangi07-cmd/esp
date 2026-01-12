#import <UIKit/UIKit.h>

// --- シンプルなESPボタンと枠のテスト ---

static UIButton *testBtn;
static UIView *testBox;

%hook UIWindow

// ゲームのウィンドウが作られた後にボタンを置くじょ
- (void)makeKeyAndVisible {
    %orig; // 元の処理を実行
    
    // すでにボタンがあったら作らない
    if (testBtn) return;

    // 1. ESP動作確認用の青い枠
    testBox = [[UIView alloc] initWithFrame:CGRectMake(100, 200, 100, 100)];
    testBox.layer.borderColor = [UIColor cyanColor].CGColor;
    testBox.layer.borderWidth = 3.0;
    testBox.hidden = YES; // 最初は隠す
    [self addSubview:testBox];

    // 2. 左上のスイッチボタン
    testBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    testBtn.frame = CGRectMake(50, 50, 100, 40);
    [testBtn setTitle:@"ESP: OFF" forState:UIControlStateNormal];
    [testBtn setBackgroundColor:[UIColor redColor]];
    [testBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // ボタンを押した時の動作を設定
    [testBtn addTarget:self action:@selector(toggleEspAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:testBtn];
}

%new
- (void)toggleEspAction {
    if (testBox.hidden) {
        testBox.hidden = NO;
        [testBtn setTitle:@"ESP: ON" forState:UIControlStateNormal];
        [testBtn setBackgroundColor:[UIColor greenColor]];
    } else {
        testBox.hidden = YES;
        [testBtn setTitle:@"ESP: OFF" forState:UIControlStateNormal];
        [testBtn setBackgroundColor:[UIColor redColor]];
    }
}
%end
