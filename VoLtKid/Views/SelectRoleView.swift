/**
 * 角色选择页
 * 横向分页展示可选角色，支持缩放动画效果
 */
import SwiftUI

/**
 * 角色选择视图
 */
struct SelectRoleView: View {
    /// 当前选中的角色索引
    @State private var selectedIndex = 0
    
    /// 控制导航到关卡地图
    @State private var showLevelMap = false
    
    /// 游戏状态管理
    @StateObject private var gameState = GameState.shared
    
    /// 可选角色列表(从Resources/Roles目录动态获取)
    private let roles = [
        "角色选择_角色1",
        "角色选择_角色2", 
        "角色选择_角色3"
    ]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 40) {
                    // 顶部标题
                    VStack(spacing: 10) {
                        Text("选择你的角色")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("每个角色都有独特的能力")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 60)
                    
                    // 角色选择区域
                    TabView(selection: $selectedIndex) {
                        ForEach(Array(roles.enumerated()), id: \.offset) { index, roleName in
                            VStack(spacing: 25) {
                                // 角色占位图标
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: getRoleColors(index: index),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 220, height: 220)
                                    
                                    Image(systemName: getRoleIcon(index: index))
                                        .font(.system(size: 80, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                .scaleEffect(index == selectedIndex ? 1.0 : 0.7)
                                .opacity(index == selectedIndex ? 1.0 : 0.6)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.8),
                                    value: selectedIndex
                                )
                                .shadow(
                                    color: index == selectedIndex ? .blue.opacity(0.3) : .clear,
                                    radius: index == selectedIndex ? 15 : 0
                                )
                                
                                // 角色信息
                                VStack(spacing: 8) {
                                    Text("角色 \(index + 1)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Text(getRoleDescription(index: index))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                }
                                .scaleEffect(index == selectedIndex ? 1.0 : 0.8)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.8),
                                    value: selectedIndex
                                )
                            }
                            .tag(index)
                        }
                    }
                    #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                #endif
                    .frame(height: 400)
                    
                    // 选择按钮
                    NavigationLink(destination: LevelMapView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                            Text("选择该角色")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 35)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            // 保存选择的角色
                            gameState.selectedHeroIndex = selectedIndex
                            gameState.saveGameProgress()
                        }
                    )
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .background(
                LinearGradient(
                    colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .navigationBarBackButtonHidden(false)
        .onAppear {
            selectedIndex = gameState.selectedHeroIndex
        }
    }
    
    /**
     * 获取角色描述文本
     * @param index 角色索引
     * @return 角色描述
     */
    private func getRoleDescription(index: Int) -> String {
        switch index {
        case 0:
            return "勇敢的电路探险家\n擅长快速连接电路"
        case 1:
            return "智慧的电学工程师\n能发现最优路径"
        case 2:
            return "活泼的电子小精灵\n拥有特殊跳跃能力"
        default:
            return "神秘的角色\n等待你来发现"
        }
    }
    
    /**
     * 获取角色对应的SF Symbol图标
     * @param index 角色索引
     * @return SF Symbol名称
     */
    private func getRoleIcon(index: Int) -> String {
        switch index {
        case 0:
            return "bolt.circle.fill"
        case 1:
            return "lightbulb.circle.fill"
        case 2:
            return "star.circle.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
    
    /**
     * 获取角色对应的渐变色彩
     * @param index 角色索引
     * @return 渐变色数组
     */
    private func getRoleColors(index: Int) -> [Color] {
        switch index {
        case 0:
            return [.orange, .red]
        case 1:
            return [.blue, .purple]
        case 2:
            return [.green, .teal]
        default:
            return [.gray, .black]
        }
    }
}

/**
 * 预览支持
 */
#Preview {
    SelectRoleView()
}
