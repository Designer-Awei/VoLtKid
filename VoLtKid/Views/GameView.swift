/**
 * 游戏主界面
 * 集成SpriteKit六边形场景，处理游戏逻辑
 */
import SwiftUI
import SpriteKit

/**
 * 游戏视图
 */
struct GameView: View {
    /// 当前关卡数据
    let level: Level
    
    /// 游戏场景实例
    @State private var scene: HexScene?
    
    /// 游戏状态
    @State private var gameStatus: GameStatus = .playing
    
    /// 显示胜利弹窗
    @State private var showVictoryAlert = false
    
    /// 获得的星级
    @State private var earnedStars = 0
    
    /// 导航控制
    @Environment(\.dismiss) private var dismiss
    
    /// 是否显示暂停菜单
    @State private var showPauseMenu = false
    
    /// 胜利弹窗状态
    @State private var victoryState: VictoryState = .hidden
    
    /// 游戏状态监听（用于角色切换）
    @StateObject private var gameState = GameState.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // SpriteKit游戏场景
                if let scene = scene {
                    SpriteView(scene: scene)
                        .ignoresSafeArea()
                } else {
                    // 加载中状态
                    ZStack {
                        Color.black.ignoresSafeArea()
                        ProgressView("加载中...")
                            .foregroundColor(.white)
                    }
                }
                
                // 游戏UI覆盖层
                VStack {
                    // 顶部状态栏
                    gameStatusBar
                    
                    Spacer()
                    
                    // 底部控制栏(如果需要)
                    if gameStatus == .playing {
                        gameControlBar
                    }
                }
                .padding()
                
                // 暂停菜单覆盖层
                if showPauseMenu {
                    PauseMenuView(
                        isPresented: $showPauseMenu,
                        onResume: {
                            // 恢复游戏逻辑
                        },
                        onRestart: {
                            restartLevel()
                        }
                    )
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            setupGameScene()
        }
        .onChange(of: gameState.selectedHeroIndex) { _ in
            // 当角色切换时，更新游戏场景中的角色外观
            scene?.updatePlayerCharacter()
        }
        .overlay(
            // 自定义胜利弹窗
            victoryState == .showing ? victoryOverlay : nil
        )
    }
    
    /**
     * 顶部游戏状态栏
     */
    private var gameStatusBar: some View {
        HStack {
            // 返回按钮
            Button(action: {
                // 返回关卡地图
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
            
            // 关卡信息
            VStack(alignment: .center, spacing: 4) {
                Text("关卡 \(level.id)")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(level.title)
                    .font(.caption)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.5))
            .cornerRadius(15)
            
            Spacer()
            
            // 暂停菜单按钮
            Button(action: {
                showPauseMenu = true
            }) {
                Image(systemName: "pause.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
        }
    }
    
    /**
     * 底部游戏控制栏
     */
    private var gameControlBar: some View {
        HStack {
            // 提示按钮
            Button(action: {
                scene?.showHint()
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "lightbulb")
                        .foregroundColor(.orange)
                    Text("提示")
                        .foregroundColor(.white)
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // 游戏状态文本
            Text(getStatusText())
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.5))
                .cornerRadius(15)
            
            Spacer()
            
            // 撤销按钮
            Button(action: {
                scene?.undoLastMove()
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.uturn.backward")
                        .foregroundColor(.blue)
                    Text("撤销")
                        .foregroundColor(.white)
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
        }
    }
    
    /**
     * 设置游戏场景
     */
    private func setupGameScene() {
        let newScene = HexScene(level: level)
        #if os(iOS)
        newScene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        #elseif os(macOS)
        newScene.size = CGSize(width: 800, height: 600) // macOS默认窗口大小
        #endif
        newScene.scaleMode = .resizeFill
        
        // 设置游戏回调
        newScene.onGameComplete = { stars in
            DispatchQueue.main.async {
                earnedStars = stars
                gameStatus = .completed
                victoryState = .showing
                print("🎯 游戏完成回调触发，显示胜利弹窗")
            }
        }
        
        newScene.onGameStatusChange = { status in
            gameStatus = status
        }
        
        scene = newScene
    }
    
    /**
     * 重新开始关卡
     */
    private func restartLevel() {
        print("🔄 重新开始关卡")
        victoryState = .hidden
        gameStatus = .playing
        earnedStars = 0
        setupGameScene()
    }
    
    /**
     * 获取当前状态文本
     */
    private func getStatusText() -> String {
        switch gameStatus {
        case .playing:
            return "点击角色开始连接电路"
        case .connecting:
            return "正在连接电路..."
        case .completed:
            return "关卡完成！"
        case .failed:
            return "电路连接错误"
        }
    }
    
    /**
     * 自定义胜利弹窗
     */
    private var victoryOverlay: some View {
        ZStack {
            // 背景遮罩
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    // 点击背景不关闭弹窗，强制用户选择
                }
            
            // 弹窗内容
            VStack(spacing: 25) {
                // 胜利图标
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                }
                
                // 文字信息
                VStack(spacing: 12) {
                    Text("关卡完成！")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("恭喜完成关卡！获得 \(earnedStars) 颗星！")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // 按钮区域
                VStack(spacing: 12) {
                    // 继续按钮
                    Button {
                        handleContinueButton()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                            Text("继续")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(victoryState == .processing)
                    
                    // 重新挑战按钮
                    Button {
                        handleRestartButton()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle.fill")
                            Text("重新挑战")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange)
                        .cornerRadius(12)
                    }
                    .disabled(victoryState == .processing)
                }
                .padding(.horizontal, 20)
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(getDialogBackgroundColor())
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 50)
        }
        .scaleEffect(victoryState == .showing ? 1.0 : 0.9)
        .opacity(victoryState == .showing ? 1.0 : 0.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: victoryState)
    }
    
    /**
     * 处理继续按钮点击
     */
    private func handleContinueButton() {
        print("🎯 点击继续按钮")
        guard victoryState == .showing else { return }
        
        victoryState = .processing
        
        // 先保存进度
        GameState.shared.completeLevel(level.id, stars: earnedStars)
        
        // 延迟关闭弹窗和返回
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            victoryState = .hidden
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                dismiss()
            }
        }
    }
    
    /**
     * 处理重新挑战按钮点击
     */
    private func handleRestartButton() {
        print("🔄 点击重新挑战按钮")
        guard victoryState == .showing else { return }
        
        victoryState = .processing
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            victoryState = .hidden
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                restartLevel()
            }
        }
    }
    
    /**
     * 获取对话框背景颜色
     */
    private func getDialogBackgroundColor() -> Color {
#if os(iOS)
        return Color(UIColor.systemBackground)
#else
        return Color(NSColor.controlBackgroundColor)
#endif
    }
}

/**
 * 游戏状态枚举
 */
enum GameStatus {
    case playing    // 游戏中
    case connecting // 连接中
    case completed  // 完成
    case failed     // 失败
}

/**
 * 胜利弹窗状态
 */
enum VictoryState {
    case hidden     // 隐藏
    case showing    // 显示中
    case processing // 处理中
}

/**
 * 预览支持
 */
#Preview {
    GameView(level: Level(
        id: 1,
        title: "测试关卡",
        star: 3,
        floatOffset: [0, 0],
        size: 3,
        components: [
            ComponentData(type: "battery", q: 0, r: 0),
            ComponentData(type: "bulb", q: 1, r: 0)
        ],
        startPos: AxialCoordinate(q: 0, r: 0)
    ))
}
