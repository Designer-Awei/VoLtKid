/**
 * 登录页面
 * 应用的首页，包含背景、动态人物动画和进入游戏按钮
 */
import SwiftUI

/**
 * 登录页面视图
 */
struct LoginView: View {
    /// 游戏状态管理
    @StateObject private var gameState = GameState.shared
    
    /// 动画控制
    @State private var logoRotation: Double = 0
    @State private var characterScale: CGFloat = 1.0
    @State private var showEnterButton = false
    @State private var navigateToGame = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // 背景渐变
                    backgroundGradient
                    
                    // 主要内容区域
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 100)

                        // LOGO区域
                        logoSection

                        Spacer()

                        // 进入游戏按钮
                        if showEnterButton {
                            enterGameButton
                                .transition(.scale.combined(with: .opacity))
                        }

                        Spacer()
                            .frame(height: 120)
                    }
                    .padding(.horizontal, 30)
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                startAnimations()
            }
            .background(
                NavigationLink(
                    destination: destinationView(),
                    isActive: $navigateToGame,
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
                    Color.purple.opacity(0.9),
                    Color.blue.opacity(0.7),
                    Color.indigo.opacity(0.8),
                    Color.cyan.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // 装饰性圆圈和形状
            VStack {
                HStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 180, height: 180)
                        .offset(x: -50, y: -30)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.yellow.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .offset(x: 40, y: 20)
                }
                Spacer()
                HStack {
                    Circle()
                        .fill(Color.pink.opacity(0.15))
                        .frame(width: 200, height: 200)
                        .offset(x: -30, y: 40)
                    Spacer()
                }
            }
            
            // 移动的小星星
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 3, height: 3)
                    .position(
                        x: CGFloat.random(in: 50...350),
                        y: CGFloat.random(in: 100...600)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 2...4))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.5),
                        value: logoRotation
                    )
            }
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
                    .frame(width: 200, height: 200)
                    .scaleEffect(characterScale)
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .rotationEffect(.degrees(logoRotation))
            }
            
            VStack(spacing: 12) {
                Text("VoLtKid")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
                
                Text("电路小英雄")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
        }
    }
    
    
    /**
     * 进入游戏按钮
     */
    private var enterGameButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                navigateToGame = true
            }
        }) {
            HStack(spacing: 20) {
                Image(systemName: "play.fill")
                    .font(.title2)
                
                Text("进入游戏")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Image(systemName: "arrow.right")
                    .font(.title3)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 50)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [.green, .teal, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(30)
            .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 6)
            .scaleEffect(1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showEnterButton)
    }
    
    /**
     * 开始动画
     */
    private func startAnimations() {
        // LOGO旋转动画
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            logoRotation = 360
        }
        
        // 角色缩放动画
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            characterScale = 1.1
        }
        
        // 延迟显示进入游戏按钮
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                showEnterButton = true
            }
        }
    }
    
    /**
     * 根据首次启动状态决定目标页面
     */
    private func destinationView() -> some View {
        if gameState.isFirstLaunch {
            return AnyView(TutorialDialogView())
        } else {
            return AnyView(MainHomeView())
        }
    }
    
}

/**
 * 预览支持
 */
#Preview {
    LoginView()
}
