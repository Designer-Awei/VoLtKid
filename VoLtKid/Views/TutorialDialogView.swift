/**
 * 新手教程对话页面
 * 展示角色对话和基础游戏介绍
 */
import SwiftUI

/**
 * 新手教程对话视图
 */
struct TutorialDialogView: View {
    /// 当前对话索引
    @State private var currentDialogIndex = 0
    
    /// 是否显示下一步动画
    @State private var showNextAnimation = false
    
    /// 是否导航到教程游戏
    @State private var navigateToTutorialGame = false
    
    /// 是否从主菜单触发
    var fromMainMenu: Bool = false
    
    /// 导航控制
    @Environment(\.dismiss) private var dismiss
    
    /// 对话内容数组
    private let dialogs = [
        TutorialDialog(
            speaker: "小电",
            text: "欢迎来到一关！",
            description: "一个学习电路的神奇世界。在这里你将学会电路的基本组成，并通过连接线路来点亮灯泡。",
            hasNext: true
        ),
        TutorialDialog(
            speaker: "小电",
            text: "游戏很简单！",
            description: "只需要用手指点击角色，然后移动到电路元件上就能激活它们。当你连接足够的元件形成完整电路时，就能获得胜利！",
            hasNext: true
        ),
        TutorialDialog(
            speaker: "小电",
            text: "准备好了吗？",
            description: "让我们开始第一个练习关卡，我会在旁边指导你的！",
            hasNext: false
        )
    ]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // 背景渐变
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.green.opacity(0.8),
                            Color.blue.opacity(0.6),
                            Color.teal.opacity(0.9)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    // 背景装饰元素
                    VStack {
                        HStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 100, height: 100)
                            Spacer()
                        }
                        Spacer()
                        HStack {
                            Spacer()
                            Circle()
                                .fill(Color.yellow.opacity(0.15))
                                .frame(width: 60, height: 60)
                        }
                        Spacer()
                        HStack {
                            Circle()
                                .fill(Color.pink.opacity(0.1))
                                .frame(width: 120, height: 120)
                            Spacer()
                        }
                    }
                    .padding()
                    
                    // 主要内容
                    VStack(spacing: 30) {
                        Spacer()
                        
                        // 角色头像区域
                        VStack(spacing: 20) {
                            // 角色头像
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.9))
                                    .frame(width: 150, height: 150)
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: "bolt.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.orange)
                            }
                            .scaleEffect(showNextAnimation ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: showNextAnimation)
                            
                            // 角色名字
                            Text(dialogs[currentDialogIndex].speaker)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 2)
                        }
                        
                        Spacer()
                        
                        // 对话框区域
                        dialogBox
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                startNextAnimation()
            }
            .background(
                NavigationLink(
                    destination: TutorialGameView(fromMainMenu: fromMainMenu),
                    isActive: $navigateToTutorialGame,
                    label: { EmptyView() }
                )
                .hidden()
            )
        }
    }
    
    /**
     * 对话框视图
     */
    private var dialogBox: some View {
        VStack(spacing: 0) {
            // 对话框主体
            VStack(spacing: 15) {
                // 主要对话文本
                Text(dialogs[currentDialogIndex].text)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                // 描述文本
                Text(dialogs[currentDialogIndex].description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
            
            // 对话框尖角（全部去掉）
            // Triangle()
            //     .fill(Color.white.opacity(0.95))
            //     .frame(width: 20, height: 15)
            //     .offset(y: -1)
        }
        .padding(.horizontal, 30)
        .onTapGesture {
            handleDialogTap()
        }
    }
    
    /**
     * 处理对话框点击
     */
    private func handleDialogTap() {
        if dialogs[currentDialogIndex].hasNext {
            // 进入下一个对话
            withAnimation(.easeInOut(duration: 0.3)) {
                currentDialogIndex += 1
            }
        } else {
            // 进入教程游戏
            navigateToTutorialGame = true
        }
    }
    
    /**
     * 开始下一步提示动画
     */
    private func startNextAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showNextAnimation = true
        }
    }
}

/**
 * 对话数据模型
 */
struct TutorialDialog {
    let speaker: String
    let text: String
    let description: String
    let hasNext: Bool
}

/**
 * 三角形形状（对话框指向角色的尖角）
 */
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

/**
 * 预览支持
 */
#Preview {
    TutorialDialogView()
}
