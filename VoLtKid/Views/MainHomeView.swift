/**
 * 主页视图
 * 替换原有封面页，作为常驻主页，包含进入关卡、选择角色、右上角菜单等功能
 */
import SwiftUI

/**
 * 主页视图
 */
struct MainHomeView: View {
    /// 游戏状态管理
    @StateObject private var gameState = GameState.shared
    
    /// 是否显示角色选择
    @State private var showRoleSelection = false
    
    /// 是否显示主菜单
    @State private var showMainMenu = false
    
    /// 是否显示新手引导
    @State private var showTutorial = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // 背景渐变
                    backgroundGradient
                    
                    // 主要内容区域
                    VStack(spacing: 50) {
                        Spacer()
                        
                        // LOGO区域
                        logoSection
                        
                        // 功能按钮区域
                        actionButtonsSection
                        
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    
                    // 顶部菜单按钮
                    VStack {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                showMainMenu = true
                            }) {
                                Image(systemName: "line.horizontal.3")
                                    .font(.system(size: 32, weight: .heavy))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                    
                    // 角色选择覆盖层
                    if showRoleSelection {
                        roleSelectionOverlay
                    }
                    
                    // 主菜单覆盖层
                    if showMainMenu {
                        MainMenuView(
                            isPresented: $showMainMenu,
                            onTutorial: {
                                showTutorial = true
                            },
                            volume: $gameState.volume
                        )
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .background(
                NavigationLink(
                    destination: TutorialDialogView(fromMainMenu: true),
                    isActive: $showTutorial,
                    label: { EmptyView() }
                )
                .hidden()
            )
        }
    }
    
    /**
     * 背景渐变
     */
    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.8),
                    Color.purple.opacity(0.6),
                    Color.indigo.opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // 装饰性圆圈
            VStack {
                HStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 150, height: 150)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.yellow.opacity(0.15))
                        .frame(width: 100, height: 100)
                }
                Spacer()
                HStack {
                    Circle()
                        .fill(Color.pink.opacity(0.1))
                        .frame(width: 200, height: 200)
                    Spacer()
                }
            }
            .padding()
        }
    }
    
    /**
     * LOGO区域
     */
    private var logoSection: some View {
        VStack(spacing: 25) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 180, height: 180)
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.yellow)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .scaleEffect(1.0)
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: UUID())
            
            VStack(spacing: 8) {
                Text("VoLtKid")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
                
                Text("电路小英雄")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
        }
    }
    
    /**
     * 功能按钮区域
     */
    private var actionButtonsSection: some View {
        VStack(spacing: 25) {
            // 进入关卡按钮
            NavigationLink(destination: LevelMapView()) {
                actionButton(
                    icon: "play.fill",
                    title: "开始冒险",
                    subtitle: "挑战电路关卡",
                    colors: [.green, .teal]
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // 选择角色按钮
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showRoleSelection = true
                }
            }) {
                actionButton(
                    icon: getCurrentRoleIcon(),
                    title: "选择角色",
                    subtitle: "当前: \(CharacterConfig.getCharacterName(at: gameState.selectedHeroIndex))",
                    colors: getCurrentRoleColors()
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    /**
     * 功能按钮
     */
    private func actionButton(icon: String, title: String, subtitle: String, colors: [Color]) -> some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.title3)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 20)
        .background(
            LinearGradient(
                colors: colors,
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    /**
     * 角色选择覆盖层
     */
    private var roleSelectionOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showRoleSelection = false
                    }
                }
            
            VStack(spacing: 30) {
                // 标题
                Text("选择角色")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // 角色网格
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 20) {
                    ForEach(0..<5, id: \.self) { index in
                        roleButton(index: index)
                    }
                }
                
                // 确认按钮
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showRoleSelection = false
                    }
                    gameState.saveGameProgress()
                }) {
                    Text("确认选择")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(
                                colors: [.green, .teal],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 40)
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
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: getRoleColors(index: index),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: getRoleIcon(index: index))
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                }
                .scaleEffect(gameState.selectedHeroIndex == index ? 1.2 : 1.0)
                .overlay(
                    Circle()
                        .stroke(
                            gameState.selectedHeroIndex == index ? Color.white : Color.clear,
                            lineWidth: 3
                        )
                        .frame(width: 80, height: 80)
                )
                
                Text(CharacterConfig.getCharacterName(at: index))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: gameState.selectedHeroIndex)
    }
    
    /**
     * 获取当前角色图标
     */
    private func getCurrentRoleIcon() -> String {
        return CharacterConfig.getCharacterIcon(at: gameState.selectedHeroIndex)
    }
    
    /**
     * 获取当前角色颜色
     */
    private func getCurrentRoleColors() -> [Color] {
        return CharacterConfig.getCharacterColors(at: gameState.selectedHeroIndex)
    }
    
    /**
     * 获取角色图标
     */
    private func getRoleIcon(index: Int) -> String {
        return CharacterConfig.getCharacterIcon(at: index)
    }
    
    /**
     * 获取角色颜色
     */
    private func getRoleColors(index: Int) -> [Color] {
        return CharacterConfig.getCharacterColors(at: index)
    }
}

/**
 * 预览支持
 */
#Preview {
    MainHomeView()
}
