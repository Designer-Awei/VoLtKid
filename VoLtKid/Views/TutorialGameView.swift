/**
 * 新手教程游戏引导页面
 * 展示六边形游戏界面的操作指导
 */
import SwiftUI
import SpriteKit

/**
 * 新手教程游戏视图
 */
struct TutorialGameView: View {
    /// 当前引导步骤
    @State private var currentStep = 0
    
    /// 是否显示引导覆盖层
    @State private var showGuidance = true
    
    /// 是否显示完成动画
    @State private var showCompletion = false
    
    /// 是否从主菜单触发
    var fromMainMenu: Bool = false
    
    /// 导航控制
    @Environment(\.presentationMode) var presentationMode
    
    /// 引导步骤数据
    private let guideSteps = [
        GuideStep(
            title: "点击角色开始",
            description: "点击蓝色角色开启连线模式",
            targetPosition: CGPoint(x: 0.3, y: 0.7),
            isCircle: true
        ),
        GuideStep(
            title: "移动到电池",
            description: "将角色移动到绿色电池上",
            targetPosition: CGPoint(x: 0.5, y: 0.5),
            isCircle: false
        ),
        GuideStep(
            title: "连接到灯泡",
            description: "继续移动到黄色灯泡完成电路",
            targetPosition: CGPoint(x: 0.7, y: 0.3),
            isCircle: false
        )
    ]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // 游戏场景背景
                    gameSceneBackground
                    
                    // 引导覆盖层
                    if showGuidance && !showCompletion {
                        guidanceOverlay(geometry: geometry)
                    }
                    
                    // 完成庆祝动画
                    if showCompletion {
                        completionOverlay
                    }
                    
                    // 顶部提示栏
                    VStack {
                        topInstructionBar
                        Spacer()
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                startTutorial()
            }
        }
    }
    
    /**
     * 游戏场景背景（模拟六边形游戏界面）
     */
    private var gameSceneBackground: some View {
        ZStack {
            // 背景色
            Color.black.opacity(0.1)
                .ignoresSafeArea()
            
            // 六边形网格（简化版）
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 15) {
                ForEach(0..<12, id: \.self) { index in
                    hexTile(index: index)
                }
            }
            .padding()
            
            // 模拟游戏元素
            gameElements
        }
    }
    
    /**
     * 六边形格子
     */
    private func hexTile(index: Int) -> some View {
        let isSpecial = [4, 6, 9].contains(index) // 特殊位置：角色、电池、灯泡
        
        return ZStack {
            // 六边形形状
            RegularPolygon(sides: 6)
                .fill(isSpecial ? Color.white.opacity(0.3) : Color.gray.opacity(0.1))
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                .frame(width: 60, height: 60)
            
            // 特殊元素
            if index == 4 {
                // 角色位置
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 40, height: 40)
                    
                    Text("1")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            } else if index == 6 {
                // 电池位置
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.green)
                    .frame(width: 25, height: 35)
            } else if index == 9 {
                // 灯泡位置
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 30, height: 30)
            }
        }
    }
    
    /**
     * 游戏元素（角色、电池、灯泡的固定位置版本）
     */
    private var gameElements: some View {
        GeometryReader { geometry in
            ZStack {
                // 这里可以添加更多游戏元素
                EmptyView()
            }
        }
    }
    
    /**
     * 引导覆盖层
     */
    private func guidanceOverlay(geometry: GeometryProxy) -> some View {
        ZStack {
            // 半透明遮罩
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            // 高亮圆圈
            Circle()
                .fill(Color.clear)
                .stroke(Color.white, lineWidth: 3)
                .frame(width: guideSteps[currentStep].isCircle ? 80 : 100, height: guideSteps[currentStep].isCircle ? 80 : 100)
                .position(
                    x: geometry.size.width * guideSteps[currentStep].targetPosition.x,
                    y: geometry.size.height * guideSteps[currentStep].targetPosition.y
                )
                .scaleEffect(showGuidance ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: showGuidance)
            
            // 引导文本框
            VStack {
                Spacer()
                
                guidanceTextBox
                    .padding(.bottom, 80)
            }
        }
        .onTapGesture {
            nextStep()
        }
    }
    
    /**
     * 引导文本框
     */
    private var guidanceTextBox: some View {
        VStack(spacing: 15) {
            Text(guideSteps[currentStep].title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(guideSteps[currentStep].description)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
            
            // 步骤指示器
            HStack(spacing: 8) {
                ForEach(0..<guideSteps.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentStep ? Color.white : Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 10)
            
            // 点击提示
            Text("点击屏幕继续")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 5)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.8))
        )
        .padding(.horizontal, 40)
    }
    
    /**
     * 完成覆盖层
     */
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 庆祝图标
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 150, height: 150)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                }
                .scaleEffect(showCompletion ? 1.2 : 1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showCompletion)
                
                VStack(spacing: 15) {
                    Text("教程完成！")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("你已经掌握了基本操作\n现在可以开始正式的冒险了！")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                
                // 开始游戏/返回主页按钮
                Button(action: {
                    if fromMainMenu {
                        // 从主菜单触发，返回主页
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        // 首次启动，标记完成并返回到主页
                        GameState.shared.markFirstLaunchCompleted()
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    HStack(spacing: 15) {
                        Image(systemName: fromMainMenu ? "house.fill" : "play.fill")
                            .font(.title3)
                        Text(fromMainMenu ? "返回主页" : "开始冒险")
                            .font(.title3)
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
            }
        }
    }
    
    /**
     * 顶部指示栏
     */
    private var topInstructionBar: some View {
        HStack {
            // 返回按钮
            Button(action: {
                // 返回到对话页面或主页
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // 跳过教程按钮
            Button(action: {
                skipTutorial()
            }) {
                Text("跳过教程")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(15)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    /**
     * 开始教程
     */
    private func startTutorial() {
        currentStep = 0
        showGuidance = true
    }
    
    /**
     * 下一步
     */
    private func nextStep() {
        if currentStep < guideSteps.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
        } else {
            // 完成教程
            finishTutorial()
        }
    }
    
    /**
     * 完成教程
     */
    private func finishTutorial() {
        withAnimation(.easeInOut(duration: 0.5)) {
            showGuidance = false
            showCompletion = true
        }
    }
    
    /**
     * 跳过教程
     */
    private func skipTutorial() {
        // 直接跳转到关卡地图
        finishTutorial()
    }
}

/**
 * 引导步骤数据模型
 */
struct GuideStep {
    let title: String
    let description: String
    let targetPosition: CGPoint // 相对位置 (0-1)
    let isCircle: Bool
}

/**
 * 正多边形形状
 */
struct RegularPolygon: Shape {
    let sides: Int
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2
        let angleIncrement = 2 * Double.pi / Double(sides)
        let startAngle = -Double.pi / 2 // 从顶部开始
        
        var path = Path()
        
        for i in 0..<sides {
            let angle = startAngle + Double(i) * angleIncrement
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)
            let point = CGPoint(x: x, y: y)
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        path.closeSubpath()
        return path
    }
}

/**
 * 预览支持
 */
#Preview {
    TutorialGameView()
}
