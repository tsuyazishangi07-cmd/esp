#import <substrate.h>
#import <mach-o/dyld.h>

// --- 相棒が見つけた「住所」をここにセット！ ---
// 03A78FF0 〜 03A790B8 の中から、座標に関係ありそうなオフセットを使うニダ
#define OFFSET_SET_COORD 0x03A79000 

// 元の関数を保存する箱
void (*old_setPos)(void *self, void *pos);

// 敵の位置が更新されるたびに呼ばれる「罠」関数
void new_setPos(void *self, void *pos) {
    // 1. ここで pos（座標データ）を解析するじょ！
    // 2. HTMLのESPに送るための準備をここでやるニダ
    
    // 元の処理に戻してあげる（これを忘れるとゲームが落ちるじょ！）
    old_setPos(self, pos);
}

%ctor {
    // ゲーム（Gameバイナリ）の開始位置を取得
    uintptr_t base = (uintptr_t)_dyld_get_image_header(0);
    
    // 相棒の「住所」にフックを仕掛ける！
    MSHookFunction((void *)(base + OFFSET_SET_COORD), 
                   (void *)&new_setPos, 
                   (void **)&old_setPos);
}
