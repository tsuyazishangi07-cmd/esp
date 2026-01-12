#import <UIKit/UIKit.h>
#import <mach-o/dyld.h> // メモリのズレ（Slide）を取得するために必要だじょ

// --- グローバル変数 ---
static UIButton *menuButton;
static UIView *espOverlay;
static BOOL isEspOn = NO;
static UILabel *statusLabel;

// --- ESPを描画する透明なキャンバス ---
@interface ESPView : UIView
@end

@implementation ESPView
- (void)drawRect:(CGRect)rect {
    // ESPがOFFなら何もしない
    if (!isEspOn) return;

    // コンテキスト（お絵かきセット）を用意
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);

    // -------------------------------------------------
    // ① 動作確認用：画面の真ん中に「テスト用の青い箱」を描く
    // これが出れば、ESPシステム自体は正常に動いている証拠だじょ！
    // -------------------------------------------------
    CGContextSetStrokeColorWithColor(context, [UIColor cyanColor].CGColor);
    CGRect testBox = CGRectMake(UIScreen.mainScreen.bounds.size.width / 2 - 50, 
                                UIScreen.mainScreen.bounds.size.height / 2 - 50, 
                                100, 100);
    CGContextStrokeRect(context, testBox);

    // -------------------------------------------------
    // ② 本番：相棒のアドレスから敵の座標を読む（高精度モード）
    // -------------------------------------------------
    // ゲームのベースアドレス（開始地点）を取得
    uintptr_t slide = _dyld_get_image_vmaddr_slide(0);
    
    // 相棒のアドレスに「ズレ」を足して、現在の本当の住所を計算するじょ！
    uintptr_t targetAddress = slide + 0x03A79000; 

    // ※ ここでメモリを読んで描画する処理が入るけど、
    // もしアドレスが間違ってるとアプリが落ちるから、まずは「アドレス確認」だけするじょ
    // 本当はここで *(float*)targetAddress とかやるニダ
    
    // ログに計算結果を出す（Macのコンソールで見れるじょ）
    // NSLog(@"[ESP] Real Address: 0x%lx", targetAddress);
}
@end

// --- ボタンが押された時の動作 ---
static void toggleEsp() {
    isEspOn = !isEspOn;
    
    if (isEspOn) {
        [menuButton setTitle:@"ESP: ON" forState:UIControlStateNormal];
        [menuButton setBackgroundColor:[UIColor greenColor]];
        espOverlay.hidden = NO; // キャンバスを表示
    } else {
        [menuButton setTitle:@"ESP: OFF" forState:UIControlStateNormal];
        [menuButton setBackgroundColor:[UIColor redColor]];
        espOverlay.hidden = YES; // キャンバスを隠す
    }
    
    // 画面を再描画（drawRectを呼び出す）
    [espOverlay setNeedsDisplay];
}

// --- ゲーム起動時に実行される部分 ---
%ctor {
    // ゲームが起動して5秒後にボタンを作る（早すぎると画面がないからだじょ）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window) return;

        // 1. お絵かきレイヤー（オーバーレイ）を作る
        espOverlay = [[ESPView alloc] initWithFrame:window.bounds];
        espOverlay.backgroundColor = [UIColor clearColor]; // 透明にする
        espOverlay.userInteractionEnabled = NO; // タップはゲーム画面に通す
        espOverlay.hidden = YES; // 最初は隠しておく
        [window addSubview:espOverlay];

        // 2. スイッチボタンを作る
        menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        menuButton.frame = CGRectMake(50, 50, 120, 40); // 左上に配置
        [menuButton setTitle:@"ESP: OFF" forState:UIControlStateNormal];
        [menuButton setBackgroundColor:[UIColor redColor]];
        [menuButton addTarget:espOverlay action:@selector(setNeedsDisplay) forControlEvents:UIControlEventTouchUpInside];
        
        // ボタンを押したら toggleEsp 関数を動かす仕掛け（簡易実装）
        // ※TweakだとaddSelectorが難しいことがあるから、タッチイベントで発火させるじょ
        // ここでは簡単に、ボタンの上に透明な判定を置いてクリックさせる方法もあるけど、
        // 今回はシンプルにGestureRecognizerを使うじょ
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:window action:@selector(handleEspTap)];
        [menuButton addGestureRecognizer:tap];
        
        [window addSubview:menuButton];
    });
}

// ボタン押下を受け取るためのフック（裏技）
%hook UIWindow
%new
- (void)handleEspTap {
    toggleEsp();
}
%end
