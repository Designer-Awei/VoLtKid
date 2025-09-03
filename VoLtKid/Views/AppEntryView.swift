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
        // 总是先显示登录页面，由登录页面根据首次启动状态决定后续跳转
        LoginView()
    }
}

/**
 * 预览支持
 */
#Preview {
    AppEntryView()
}
