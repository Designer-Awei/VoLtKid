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
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            setupGameScene()
        }
        .alert("关卡完成！", isPresented: $showVictoryAlert) {
            Button("继续") {
                // 保存进度并返回地图
                GameState.shared.completeLevel(level.id, stars: earnedStars)
            }
            Button("重新挑战") {
                restartLevel()
            }
        } message: {
            Text("恭喜完成关卡！获得 \(earnedStars) 颗星！")
        }
    }
    
    /**
     * 顶部游戏状态栏
     */
    private var gameStatusBar: some View {
        HStack {
            // 返回按钮
            Button(action: {
                // 返回关卡地图
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
            
            // 重新开始按钮
            Button(action: restartLevel) {
                Image(systemName: "arrow.clockwise")
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
                    Text("提示")
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.8))
                .cornerRadius(15)
            }
            
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
                    Text("撤销")
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.8))
                .cornerRadius(15)
            }
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
            earnedStars = stars
            gameStatus = .completed
            showVictoryAlert = true
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
        setupGameScene()
        gameStatus = .playing
        showVictoryAlert = false
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
