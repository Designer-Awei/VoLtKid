/**
 * 游戏内暂停菜单
 * 包含音量控制、角色切换、退出等功能
 */
import SwiftUI

/**
 * 暂停菜单视图
 */
struct PauseMenuView: View {
    /// 是否显示菜单
    @Binding var isPresented: Bool
    
    /// 是否显示角色选择
    @State private var showRoleSelection = false
    
    /// 音量控制
    @State private var volume: Double = 0.5
    
    /// 游戏状态管理
    @StateObject private var gameState = GameState.shared
    
    /// 导航控制
    @Environment(\.presentationMode) var presentationMode
    
    /// 恢复游戏的回调
    var onResume: (() -> Void)?
    
    /// 重新开始的回调
    var onRestart: (() -> Void)?
    
    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissMenu()
                }
            
            // 主菜单内容
            VStack(spacing: 0) {
                if showRoleSelection {
                    roleSelectionContent
                } else {
                    mainMenuContent
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 5)
            )
            .padding(.horizontal, 40)
            .scaleEffect(isPresented ? 1.0 : 0.8)
            .opacity(isPresented ? 1.0 : 0.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
        }
    }
    
    /**
     * 主菜单内容
     */
    private var mainMenuContent: some View {
        VStack(spacing: 25) {
            // 标题
            HStack {
                Spacer()
                
                Text("游戏暂停")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 关闭按钮
                Button(action: dismissMenu) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // 菜单选项
            VStack(spacing: 15) {
                // 继续游戏
                menuButton(
                    icon: "play.fill",
                    title: "继续游戏",
                    color: .green
                ) {
                    dismissMenu()
                    onResume?()
                }
                
                // 音量控制
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "speaker.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                        
                        Text("音量")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "speaker.wave.1")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Slider(value: $volume, in: 0...1)
                            .accentColor(.blue)
                        
                        Image(systemName: "speaker.wave.3")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                )
                
                // 切换角色
                menuButton(
                    icon: "person.2.fill",
                    title: "切换角色",
                    color: .purple
                ) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showRoleSelection = true
                    }
                }
                
                // 重新开始
                menuButton(
                    icon: "arrow.clockwise",
                    title: "重新开始",
                    color: .orange
                ) {
                    dismissMenu()
                    onRestart?()
                }
                
                // 退出到地图
                menuButton(
                    icon: "map.fill",
                    title: "返回地图",
                    color: .red
                ) {
                    dismissMenu()
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    /**
     * 角色选择内容
     */
    private var roleSelectionContent: some View {
        VStack(spacing: 25) {
            // 标题栏
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showRoleSelection = false
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("选择角色")
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
            
            // 角色网格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 3), spacing: 15) {
                ForEach(0..<5, id: \.self) { index in
                    roleButton(index: index)
                }
            }
            .padding(.horizontal, 20)
            
            // 确认按钮
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showRoleSelection = false
                }
                gameState.saveGameProgress()
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                    Text("确认选择")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.green, .teal],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.bottom, 20)
        }
    }
    
    /**
     * 角色按钮
     */
    private func roleButton(index: Int) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                gameState.selectedHeroIndex = index
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: getRoleColors(index: index),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: getRoleIcon(index: index))
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                }
                .scaleEffect(gameState.selectedHeroIndex == index ? 1.1 : 1.0)
                .overlay(
                    Circle()
                        .stroke(
                            gameState.selectedHeroIndex == index ? Color.blue : Color.clear,
                            lineWidth: 3
                        )
                        .frame(width: 70, height: 70)
                )
                
                Text("角色\(index + 1)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: gameState.selectedHeroIndex)
    }
    
    /**
     * 菜单按钮
     */
    private func menuButton(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
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
    
    /**
     * 获取角色颜色 (扩展到5个角色)
     */
    private func getRoleColors(index: Int) -> [Color] {
        switch index {
        case 0:
            return [.orange, .red]
        case 1:
            return [.blue, .purple]
        case 2:
            return [.green, .teal]
        case 3:
            return [.pink, .purple]
        case 4:
            return [.indigo, .blue]
        default:
            return [.gray, .black]
        }
    }
    
    /**
     * 获取角色图标 (扩展到5个角色)
     */
    private func getRoleIcon(index: Int) -> String {
        switch index {
        case 0:
            return "bolt.circle.fill"
        case 1:
            return "lightbulb.circle.fill"
        case 2:
            return "star.circle.fill"
        case 3:
            return "heart.circle.fill"
        case 4:
            return "diamond.circle.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
}

/**
 * 预览支持
 */
#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        
        PauseMenuView(isPresented: .constant(true))
    }
}
