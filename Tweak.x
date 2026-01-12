#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>

// --- 設定エリア ---
#define TARGET_OFFSET 0x03A79000 // 相棒が解析したアドレスだじょ！

static UIButton *menuButton;
static UIView *espBox;
static BOOL isEspOn = NO;

// --- メモリを読み取るための関数 ---
// 難しい計算（ASLR補正）を自動でやってくれる魔法の関数だじょ
template <typename T>
T ReadMemory(uintptr_t address) {
    uintptr_t slide = _dyld_get_image_vmaddr_slide(0);
    return *(T*)(slide + address);
}

// --- メインのタイマー処理 ---
// 1秒間に30回、敵の位置を確認して四角を動かすじょ！
static void updateEsp() {
    if (!isEspOn || !espBox) return;

    // 本来はここで「敵のリスト」をループして全員分描くけど、
    // まずは「一人目の敵」の座標をターゲットにするじょ！
    
    // ⚠️ 注意：以下のオフセット(+0x10など)はゲームによって違うから、
    // 相棒が解析した「X座標がどこにあるか」に合わせて調整が必要だじょ！
    float enemyX = ReadMemory<float>(TARGET_OFFSET + 0x0); // X座標
    float enemyY = ReadMemory<float>(TARGET_OFFSET + 0x4); // Y座標
    
    // 取得した座標を画面の座標に反映させるニダ！
    dispatch_async(dispatch_get_main_queue(), ^{
        // とりあえず座標を画面上の位置に代入してみるじょ
        // (本来はここでWorldToScreenという3D→2D変換が必要だじょ)
        espBox.center = CGPointMake(enemyX, enemyY);
    });
}

%ctor {
    // 15秒待ってからボタンと枠を作る安全設計だじょ
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window) return;

        // 1. 敵を追跡する四角
        espBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        espBox.layer.borderColor = [UIColor limeColor].CGColor;
        espBox.layer.borderWidth = 2.0;
        espBox.hidden = YES;
        [window addSubview:espBox];

        // 2. メニューボタン
        menuButton = [UIButton buttonWithType:UIButtonTypeSystem];
        menuButton.frame = CGRectMake(80, 80, 100, 40);
        [menuButton setTitle:@"ESP: OFF" forState:UIControlStateNormal];
        [menuButton setBackgroundColor:[UIColor redColor]];
        [menuButton addTarget:window action:@selector(toggleEsp) forControlEvents:UIControlEventTouchUpInside];
        [window addSubview:menuButton];

        // 定期的に座標を更新するタイマーをスタート！
        [NSTimer scheduledTimerWithTimeInterval:0.03 repeats:YES block:^(NSTimer * _Nonnull timer) {
            updateEsp();
        }];
    });
}

%hook UIWindow
%new
- (void)toggleEsp {
    isEspOn = !isEspOn;
    espBox.hidden = !isEspOn;
    if (isEspOn) {
        [menuButton setTitle:@"ESP: ON" forState:UIControlStateNormal];
        [menuButton setBackgroundColor:[UIColor greenColor]];
    } else {
        [menuButton setTitle:@"ESP: OFF" forState:UIControlStateNormal];
        [menuButton setBackgroundColor:[UIColor redColor]];
    }
}
%end
