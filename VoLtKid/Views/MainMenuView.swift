/**
 * 主页菜单视图
 * 包含音量调节、新手引导、帮助等功能
 */
import SwiftUI

/**
 * 主菜单视图
 */
struct MainMenuView: View {
    /// 是否显示菜单
    @Binding var isPresented: Bool
    
    /// 新手引导回调
    var onTutorial: (() -> Void)?
    
    /// 音量绑定
    @Binding var volume: Double
    
    /// 是否显示帮助页面
    @State private var showHelp = false
    
    /// 游戏状态管理
    @StateObject private var gameState = GameState.shared
    
    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissMenu()
                }
            
            // 菜单内容
            VStack(spacing: 0) {
                // 标题栏
                menuHeader
                
                // 菜单选项
                menuOptions
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 5)
            )
            .padding(.horizontal, 50)
            .scaleEffect(isPresented ? 1.0 : 0.8)
            .opacity(isPresented ? 1.0 : 0.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
        }
        .background(
            NavigationLink(
                destination: HelpView(),
                isActive: $showHelp,
                label: { EmptyView() }
            )
            .hidden()
        )
    }
    
    /**
     * 菜单标题栏
     */
    private var menuHeader: some View {
        HStack {
            Spacer()
            
            Text("菜单")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: dismissMenu) {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    /**
     * 菜单选项
     */
    private var menuOptions: some View {
        VStack(spacing: 20) {
            // 音量控制
            volumeControl
            
            Divider()
                .padding(.horizontal, 20)
            
            // 新手引导
            menuButton(
                icon: "questionmark.circle.fill",
                title: "新手引导",
                subtitle: "重新学习游戏玩法",
                color: .blue
            ) {
                dismissMenu()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onTutorial?()
                }
            }
            
            // 帮助
            menuButton(
                icon: "info.circle.fill",
                title: "帮助",
                subtitle: "了解游戏规则和电路知识",
                color: .green
            ) {
                dismissMenu()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showHelp = true
                }
            }
            
            // 关于游戏
            menuButton(
                icon: "heart.circle.fill",
                title: "关于游戏",
                subtitle: "VoLtKid v1.0",
                color: .pink
            ) {
                // 可以添加关于页面或版本信息
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 25)
    }
    
    /**
     * 音量控制
     */
    private var volumeControl: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "speaker.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text("音量")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Int(volume * 100))%")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "speaker.wave.1")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Slider(value: $volume, in: 0...1) { editing in
                    if !editing {
                        // 音量改变完成时保存
                        gameState.volume = volume
                        gameState.saveGameProgress()
                    }
                }
                .accentColor(.orange)
                
                Image(systemName: "speaker.wave.3")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
        )
    }
    
    /**
     * 菜单按钮
     */
    private func menuButton(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    /**
     * 关闭菜单
     */
    private func dismissMenu() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isPresented = false
        }
    }
}

/**
 * 预览支持
 */
#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        
        MainMenuView(
            isPresented: .constant(true),
            onTutorial: {},
            volume: .constant(0.5)
        )
    }
}
