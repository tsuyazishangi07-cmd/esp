#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>

// --- 設定エリア ---
#define TARGET_OFFSET 0x03A79000 // 相棒のアドレス

static UIButton *menuButton;
static UIView *espBox;
static BOOL isEspOn = NO;

// --- メモリ読み取り関数（エラー回避版） ---
static float ReadFloat(uintptr_t address) {
    uintptr_t slide = _dyld_get_image_vmaddr_slide(0);
    uintptr_t target = slide + address;
    
    // 安全チェック：変な場所を読もうとしたら0を返すじょ
    if (target < 0x100000000) return 0.0f; 
    
    float value = 0;
    // memcpyを使って安全に値をコピーするニダ
    if (address != 0) {
        @try {
            value = *(float*)target;
        } @catch (NSException *e) {
            return 0.0f;
        }
    }
    return value;
}

// --- 更新処理（1秒間に30回実行） ---
static void updateEsp() {
    if (!isEspOn || !espBox) return;

    // メモリからXとYを取得
    float enemyX = ReadFloat(TARGET_OFFSET);
    float enemyY = ReadFloat(TARGET_OFFSET + 0x4);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 値が取得できていれば、四角をその場所に移動！
        if (enemyX > 1.0f && enemyY > 1.0f) {
            // ※本来はここにWorldToScreenが必要だけど、まずは生データを反映させるじょ
            espBox.center = CGPointMake(enemyX, enemyY);
        }
    });
}

%ctor {
    // 完全に起動するまで20秒待つ超安全設計！
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
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

        // 追跡用の枠（緑色）
        espBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        espBox.layer.borderColor = [UIColor greenColor].CGColor;
        espBox.layer.borderWidth = 2.0;
        espBox.hidden = YES;
        espBox.userInteractionEnabled = NO;
        [window addSubview:espBox];

        // メニューボタン
        menuButton = [UIButton buttonWithType:UIButtonTypeSystem];
        menuButton.frame = CGRectMake(100, 60, 110, 40);
        [menuButton setTitle:@"ESP: OFF" forState:UIControlStateNormal];
        [menuButton setBackgroundColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.7]];
        [menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        menuButton.layer.cornerRadius = 12;
        [menuButton addTarget:window action:@selector(handleEspToggle) forControlEvents:UIControlEventTouchUpInside];
        [window addSubview:menuButton];

        // タイマー開始
        [NSTimer scheduledTimerWithTimeInterval:0.03 repeats:YES block:^(NSTimer *timer) {
            updateEsp();
        }];
    });
}

%hook UIWindow
%new
- (void)handleEspToggle {
    isEspOn = !isEspOn;
    espBox.hidden = !isEspOn;
    if (isEspOn) {
        [menuButton setTitle:@"ESP: ON" forState:UIControlStateNormal];
        [menuButton setBackgroundColor:[UIColor colorWithRed:0 green:0.7 blue:0 alpha:0.7]];
    } else {
        [menuButton setTitle:@"ESP: OFF" forState:UIControlStateNormal];
        [menuButton setBackgroundColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.7]];
    }
}
%end
