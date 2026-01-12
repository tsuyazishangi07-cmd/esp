#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import "ImGuiDrawView.h"
#include "imgui.h"
#include "imgui_impl_metal.h"

@implementation ImGuiDrawView {
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
}

- (instancetype)initWithItem:(int)item {
    self = [super init];
    if (self) {
        _device = MTLCreateSystemDefaultDevice();
        _commandQueue = [_device newCommandQueue];
        
        // 🌟 ImGuiのセットアップ
        IMGUI_CHECKVERSION();
        ImGui::CreateContext();
        ImGuiIO& io = ImGui::GetIO();
        
        // 🛠 日本語フォントなどの設定が必要な場合はここに追加するじょ
        ImGui::StyleColorsDark();
        
        ImGui_ImplMetal_Init(_device);
    }
    return self;
}

// 🎨 ここがESPの描画メインエンジンだじょ！
- (void)drawRect:(CGRect)rect {
    ImGui_ImplMetal_NewFrame([MTLRenderPassDescriptor renderPassDescriptor]);
    ImGui::NewFrame();

    // 🌟 相棒！ここにメニューのコードを書くニダ！
    ImGui::Begin("Aibou ESP Menu");
    ImGui::Text("Status: Active");
    if (ImGui::Button("Test Trace")) {
        // ボタンを押した時の処理だじょ
    }
    ImGui::End();

    // 🌟 ESPの線（Box）を描画する例だじょ
    ImDrawList* drawList = ImGui::GetBackgroundDrawList();
    drawList->AddRect(ImVec2(100, 100), ImVec2(200, 200), IM_COL32(255, 0, 0, 255));

    ImGui::Render();
    ImDrawData* draw_data = ImGui::GetDrawData();
    
    // Metalのレンダリング処理（中略：実際のビルドには実装が必要だじょ）
}

@end
