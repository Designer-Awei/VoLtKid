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
    @Environment(\.dismiss) private var dismiss
    
    /// 手指动画控制
    @State private var fingerOffset: CGSize = .zero
    @State private var fingerScale: CGFloat = 1.0
    @State private var isPlayerSelected = false
    @State private var hasCompletedCircuit = false
    
    /// 引导步骤数据
    private let guideSteps = [
        TutorialGuideStep(
            title: "点击角色开始",
            description: "首先，点击下方的蓝色角色来选中它，这样就能开始连接电路了。",
            targetType: .character,
            targetPosition: CGPoint(x: 0.3, y: 0.7),
            fingerPosition: CGPoint(x: 0.3, y: 0.65),
            instruction: "轻点蓝色角色",
            needsSelection: true,
            isInteractive: true
        ),
        TutorialGuideStep(
            title: "移动到电池",
            description: "很好！现在角色已经被选中，请点击绿色的电池元件，角色会自动移动过去。",
            targetType: .battery,
            targetPosition: CGPoint(x: 0.5, y: 0.5),
            fingerPosition: CGPoint(x: 0.5, y: 0.45),
            instruction: "点击绿色电池",
            needsSelection: false,
            isInteractive: true
        ),
        TutorialGuideStep(
            title: "连接到灯泡",
            description: "做得很棒！最后一步，点击黄色的灯泡来完成电路连接，这样就能点亮灯泡了！",
            targetType: .bulb,
            targetPosition: CGPoint(x: 0.7, y: 0.3),
            fingerPosition: CGPoint(x: 0.7, y: 0.25),
            instruction: "点击黄色灯泡",
            needsSelection: false,
            isInteractive: true
        ),
        TutorialGuideStep(
            title: "完成电路",
            description: "太棒了！你已经成功连接了一个完整的电路。电流从电池流出，通过你走过的路径，最终点亮了灯泡！",
            targetType: .celebration,
            targetPosition: CGPoint(x: 0.5, y: 0.5),
            fingerPosition: CGPoint(x: 0.5, y: 0.5),
            instruction: "电路完成！",
            needsSelection: false,
            isInteractive: false
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
                        tutorialGuidanceOverlay(geometry: geometry)
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
                startFingerAnimation()
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
                        .fill(getCurrentCharacterColor())
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(isPlayerSelected ? Color.yellow : Color.clear, lineWidth: 3)
                        )
                        .scaleEffect(isPlayerSelected ? 1.1 : 1.0)
                        .animation(.spring(response: 0.5), value: isPlayerSelected)
                    
                    Text("\(GameState.shared.selectedHeroIndex + 1)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            } else if index == 6 {
                // 电池位置
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.green)
                        .frame(width: 25, height: 35)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.white, lineWidth: 2)
                        )
                    
                    // 电池极性标识
                    VStack(spacing: 2) {
                        Text("+")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("-")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(currentStep >= 1 ? 1.1 : 1.0)
                .animation(.spring(response: 0.5), value: currentStep)
            } else if index == 9 {
                // 灯泡位置
                ZStack {
                    Circle()
                        .fill(hasCompletedCircuit ? Color.yellow : Color.yellow.opacity(0.5))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .stroke(Color.orange, lineWidth: 2)
                        )
                    
                    // 灯泡中心
                    Circle()
                        .fill(hasCompletedCircuit ? Color.white : Color.white.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
                .scaleEffect(currentStep >= 2 ? 1.1 : 1.0)
                .scaleEffect(hasCompletedCircuit ? 1.2 : 1.0)
                .animation(.spring(response: 0.5), value: currentStep)
                .animation(.spring(response: 0.5), value: hasCompletedCircuit)
                
                // 完成时的光效
                if hasCompletedCircuit {
                    Circle()
                        .fill(Color.yellow.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .scaleEffect(1.5)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: hasCompletedCircuit)
                }
            }
        }
    }
    
    /**
     * 游戏元素（角色、电池、灯泡的固定位置版本）
     */
    private var gameElements: some View {
        GeometryReader { geometry in
            ZStack {
                // 连接路径可视化
                if currentStep >= 1 {
                    connectionPaths(geometry: geometry)
                }
            }
        }
    }
    
    /**
     * 连接路径
     */
    private func connectionPaths(geometry: GeometryProxy) -> some View {
        ZStack {
            // 角色到电池的路径
            if currentStep >= 2 {
                Path { path in
                    let startX = geometry.size.width * 0.3
                    let startY = geometry.size.height * 0.7
                    let midX = geometry.size.width * 0.5
                    let midY = geometry.size.height * 0.5
                    
                    path.move(to: CGPoint(x: startX, y: startY))
                    path.addLine(to: CGPoint(x: midX, y: midY))
                }
                .stroke(Color.cyan, lineWidth: 4)
                .opacity(0.8)
            }
            
            // 电池到灯泡的路径
            if hasCompletedCircuit {
                Path { path in
                    let midX = geometry.size.width * 0.5
                    let midY = geometry.size.height * 0.5
                    let endX = geometry.size.width * 0.7
                    let endY = geometry.size.height * 0.3
                    
                    path.move(to: CGPoint(x: midX, y: midY))
                    path.addLine(to: CGPoint(x: endX, y: endY))
                }
                .stroke(Color.cyan, lineWidth: 4)
                .opacity(0.8)
                
                // 完成电路的闭合路径
                Path { path in
                    let startX = geometry.size.width * 0.3
                    let startY = geometry.size.height * 0.7
                    let endX = geometry.size.width * 0.7
                    let endY = geometry.size.height * 0.3
                    
                    // 从灯泡回到角色的虚线路径
                    path.move(to: CGPoint(x: endX, y: endY))
                    path.addLine(to: CGPoint(x: startX, y: startY))
                }
                .stroke(Color.yellow, style: StrokeStyle(lineWidth: 3, dash: [5, 5]))
                .opacity(0.6)
            }
        }
    }
    
    /**
     * 新的教程引导覆盖层
     */
    private func tutorialGuidanceOverlay(geometry: GeometryProxy) -> some View {
        ZStack {
            // 半透明遮罩
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            // 高亮指向区域
            highlightTarget(geometry: geometry)
            
            // 指引手指
            if guideSteps[currentStep].isInteractive {
                guidingFinger(geometry: geometry)
            }
            
            // 底部教学区域
            VStack {
                Spacer()
                
                tutorialInstructionPanel(geometry: geometry)
            }
        }
        .onTapGesture { location in
            handleTutorialTap(location: location, geometry: geometry)
        }
    }
    
    /**
     * 高亮目标区域
     */
    private func highlightTarget(geometry: GeometryProxy) -> some View {
        let currentGuide = guideSteps[currentStep]
        let targetSize: CGFloat
        
        switch currentGuide.targetType {
        case .character:
            targetSize = 100
        case .battery, .bulb:
            targetSize = 80
        case .celebration:
            targetSize = 150
        }
        
        return Circle()
            .fill(Color.clear)
            .stroke(Color.yellow, lineWidth: 4)
            .frame(width: targetSize, height: targetSize)
            .position(
                x: geometry.size.width * currentGuide.targetPosition.x,
                y: geometry.size.height * currentGuide.targetPosition.y
            )
            .scaleEffect(showGuidance ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: showGuidance)
    }
    
    /**
     * 引导手指动画
     */
    private func guidingFinger(geometry: GeometryProxy) -> some View {
        let currentGuide = guideSteps[currentStep]
        
        return Image(systemName: "hand.point.up.left.fill")
            .font(.system(size: 40))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.5), radius: 5)
            .position(
                x: geometry.size.width * currentGuide.fingerPosition.x + fingerOffset.width,
                y: geometry.size.height * currentGuide.fingerPosition.y + fingerOffset.height
            )
            .scaleEffect(fingerScale)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: fingerScale)
    }
    
    /**
     * 教程指导面板
     */
    private func tutorialInstructionPanel(geometry: GeometryProxy) -> some View {
        HStack(spacing: 20) {
            // 左侧角色形象
            characterAvatar
            
            // 右侧文字说明
            VStack(alignment: .leading, spacing: 12) {
                Text(guideSteps[currentStep].instruction)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(guideSteps[currentStep].description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                // 步骤指示器
                HStack(spacing: 6) {
                    ForEach(0..<guideSteps.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentStep ? Color.yellow : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 8)
            }
            
            Spacer()
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.85))
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: -5)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
    
    /**
     * 角色头像
     */
    private var characterAvatar: some View {
        ZStack {
            Circle()
                .fill(getCurrentCharacterColor())
                .frame(width: 80, height: 80)
                .shadow(color: .black.opacity(0.3), radius: 5)
            
            // 使用当前选中的角色形象
            Text("\(GameState.shared.selectedHeroIndex + 1)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
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
                    
                    Text("🎉 恭喜你成功点亮了灯泡！")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                        .multilineTextAlignment(.center)
                    
                    Text("你已经掌握了以下技能：\n• 选择角色进入连线模式\n• 连接电路元件\n• 形成完整的电路回路\n\n现在可以开始正式的电路冒险了！")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
                
                // 开始游戏/返回主页按钮
                Button(action: {
                    if fromMainMenu {
                        // 从主菜单触发，返回主页
                        dismiss()
                    } else {
                        // 首次启动，标记完成并返回到主页
                        GameState.shared.markFirstLaunchCompleted()
                        dismiss()
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
                dismiss()
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
        isPlayerSelected = false
        hasCompletedCircuit = false
    }
    
    /**
     * 开始手指动画
     */
    private func startFingerAnimation() {
        // 手指轻微抖动动画
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            fingerOffset = CGSize(width: 5, height: 5)
        }
        
        // 手指缩放动画
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            fingerScale = 1.2
        }
    }
    
    /**
     * 处理教程点击
     */
    private func handleTutorialTap(location: CGPoint, geometry: GeometryProxy) {
        let currentGuide = guideSteps[currentStep]
        
        // 计算点击区域
        let targetX = geometry.size.width * currentGuide.targetPosition.x
        let targetY = geometry.size.height * currentGuide.targetPosition.y
        let targetSize: CGFloat = 100
        
        let tappedInTarget = abs(location.x - targetX) < targetSize/2 && 
                           abs(location.y - targetY) < targetSize/2
        
        if tappedInTarget && currentGuide.isInteractive {
            switch currentGuide.targetType {
            case .character:
                if !isPlayerSelected {
                    isPlayerSelected = true
                    // 模拟角色选中效果
                    withAnimation(.spring()) {
                        nextStep()
                    }
                }
                
            case .battery:
                if isPlayerSelected {
                    // 模拟移动到电池
                    withAnimation(.easeInOut(duration: 0.5)) {
                        nextStep()
                    }
                }
                
            case .bulb:
                if isPlayerSelected {
                    // 模拟完成电路连接
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                        hasCompletedCircuit = true
                    }
                    
                    // 延迟后进入下一步
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            nextStep()
                        }
                    }
                }
                
            case .celebration:
                // 完成教程
                finishTutorial()
            }
        }
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
    
    /**
     * 获取当前角色颜色
     */
    private func getCurrentCharacterColor() -> Color {
        switch GameState.shared.selectedHeroIndex {
        case 0:
            return .red
        case 1:
            return .blue
        case 2:
            return .purple
        default:
            return .blue
        }
    }
}

/**
 * 教程引导步骤数据模型
 */
struct TutorialGuideStep {
    let title: String
    let description: String
    let targetType: TargetType
    let targetPosition: CGPoint // 相对位置 (0-1)
    let fingerPosition: CGPoint // 手指指向位置 (0-1)
    let instruction: String
    let needsSelection: Bool
    let isInteractive: Bool
}

/**
 * 目标类型枚举
 */
enum TargetType {
    case character  // 角色
    case battery    // 电池
    case bulb       // 灯泡
    case celebration // 庆祝
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
