/**
 * 应用入口视图
 * 根据首次启动状态决定显示封面页+教程还是主页
 */
import SwiftUI

/**
 * 应用入口视图
 */
struct AppEntryView: View {
    /// 游戏状态管理
    @StateObject private var gameState = GameState.shared
    
    var body: some View {
        Group {
            if gameState.isFirstLaunch {
                // 首次启动：显示封面页
                CoverView()
            } else {
                // 后续启动：直接进入主页
                MainHomeView()
            }
        }
    }
}

/**
 * 预览支持
 */
#Preview {
    AppEntryView()
}
