/**
 * 游戏封面页
 * 显示背景图片、LOGO动画和开始游戏按钮
 */
import SwiftUI

/**
 * 封面页视图
 */
struct CoverView: View {
    /// 控制导航状态
    @State private var showRoleSelection = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // 背景渐变 - 替代背景图片
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
                    
                    // 背景装饰圆圈
                    VStack {
                        HStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 120, height: 120)
                            Spacer()
                        }
                        Spacer()
                        HStack {
                            Spacer()
                            Circle()
                                .fill(Color.yellow.opacity(0.2))
                                .frame(width: 80, height: 80)
                        }
                        Spacer()
                        HStack {
                            Circle()
                                .fill(Color.pink.opacity(0.15))
                                .frame(width: 150, height: 150)
                            Spacer()
                        }
                    }
                    .padding()
                    
                    // 主要内容区域
                    VStack(spacing: 60) {
                        Spacer()
                        
                        // LOGO动画区域 - 使用SwiftUI原生图标
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 200, height: 200)
                                
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.yellow)
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            
                            Text("VoLtKid")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                        }
                        
                        Spacer()
                        
                        // 开始游戏按钮
                        NavigationLink(destination: SelectRoleView()) {
                            HStack(spacing: 15) {
                                Image(systemName: "play.fill")
                                    .font(.title2)
                                Text("开始游戏")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
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
                        .scaleEffect(showRoleSelection ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: showRoleSelection)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                }
            }
        }
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
    }
}

/**
 * 预览支持
 */
#Preview {
    CoverView()
}
