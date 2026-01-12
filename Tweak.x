#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>

// --- 設定エリア ---
#define TARGET_OFFSET 0x03A79000 

static UIButton *menuButton;
// ここを UIView * に修正したじょ！
static UIView *espBox;
static BOOL isEspOn = NO;

// --- メモリを読み取るための魔法 ---
template <typename T>
T ReadMemory(uintptr_t address) {
    uintptr_t slide = _dyld_get_image_vmaddr_slide(0);
    // メモリ保護で落ちないように、安全なポインタチェックを入れるじょ
    uintptr_t target = slide + address;
    if (target < 0x100000000) return 0; 
    return *(T*)target;
}

// --- 更新処理 ---
static void updateEsp() {
    if (!isEspOn || !espBox) return;

    // 敵の座標を読み取る（相棒のアドレスを使用）
    float enemyX = ReadMemory<float>(TARGET_OFFSET);
    float enemyY = ReadMemory<float>(TARGET_OFFSET + 0x4);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 読み取った値が 0 じゃなければ、その場所に四角を移動させるじょ！
        if (enemyX != 0 && enemyY != 0) {
            espBox.center = CGPointMake(enemyX, enemyY);
        }
    });
}

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        // 最新のiOSでも画面を取れるようにするおまじない
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

        // 1. 追跡用の四角
        espBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        // 色を lime から green に変更してエラー回避だじょ！
        espBox.layer.borderColor = [UIColor greenColor].CGColor;
        espBox.layer.borderWidth = 3.0;
        espBox.hidden = YES;
        espBox.userInteractionEnabled = NO;
        [window addSubview:espBox];

        // 2. ボタン
        menuButton = [UIButton buttonWithType:UIButtonTypeSystem];
        menuButton.frame = CGRectMake(80, 80, 120, 45);
        [menuButton setTitle:@"ESP: OFF" forState:UIControlStateNormal];
        [menuButton setBackgroundColor:[UIColor redColor]];
        [menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        menuButton.layer.cornerRadius = 10;
        [menuButton addTarget:window action:@selector(toggleEsp) forControlEvents:UIControlEventTouchUpInside];
        [window addSubview:menuButton];

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
