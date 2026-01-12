#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 何もフックしない、ただ「読み込んだじょ」とログを出すだけのコードだじょ
%ctor {
    NSLog(@"[ESP_TEST] Build Success!");
}
