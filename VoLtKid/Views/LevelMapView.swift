/**
 * 关卡大地图页面
 * 显示浮岛式关卡布局，支持2.5D视觉效果和交互
 */
import SwiftUI

/**
 * 关卡地图视图
 */
struct LevelMapView: View {
    /// 关卡数据列表
    @State private var levels: [Level] = []
    
    /// 当前选中的关卡ID
    @State private var selectedLevelId: Int? = nil
    
    /// 游戏状态管理
    @StateObject private var gameState = GameState.shared
    
    /// 滚动视图代理
    @State private var scrollProxy: ScrollViewProxy? = nil
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // 背景渐变
                    LinearGradient(
                        colors: [.cyan.opacity(0.3), .blue.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    // 关卡浮岛滚动视图
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: 80) {
                                // 顶部间距
                                Spacer()
                                    .frame(height: 100)
                                
                                // 关卡浮岛列表
                                ForEach(levels) { level in
                                    FloatingIslandView(
                                        level: level,
                                        isSelected: selectedLevelId == level.id,
                                        isUnlocked: gameState.isLevelUnlocked(level.id),
                                        stars: gameState.levelStars[level.id] ?? 0,
                                        onTap: {
                                            handleLevelTap(level, proxy: proxy)
                                        }
                                    )
                                    .id(level.id)
                                }
                                
                                // 底部间距
                                Spacer()
                                    .frame(height: 200)
                            }
                            .padding(.horizontal, 40)
                        }
                        .onAppear {
                            scrollProxy = proxy
                        }
                    }
                    
                    // 顶部标题栏
                    VStack {
                        HStack {
                            Text("电路冒险之旅")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // 当前选择的角色头像
                            APNGImageView(name: "角色选择_角色\(gameState.selectedHeroIndex + 1)")
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        Spacer()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .onAppear {
            loadLevels()
        }
    }
    
    /**
     * 处理关卡点击事件
     * @param level 被点击的关卡
     * @param proxy 滚动视图代理
     */
    private func handleLevelTap(_ level: Level, proxy: ScrollViewProxy) {
        guard gameState.isLevelUnlocked(level.id) else {
            // TODO: 显示关卡未解锁提示
            return
        }
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            selectedLevelId = level.id
            
            // 滚动到关卡中心位置(屏幕底部30%处)
            proxy.scrollTo(level.id, anchor: UnitPoint(x: 0.5, y: 0.7))
        }
    }
    
    /**
     * 从JSON文件加载关卡数据
     */
    private func loadLevels() {
        guard let url = Bundle.main.url(forResource: "levels", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decodedLevels = try? JSONDecoder().decode([Level].self, from: data) else {
            print("无法加载关卡数据")
            return
        }
        
        levels = decodedLevels.sorted { $0.id < $1.id }
    }
}

/**
 * 浮岛关卡视图组件
 */
struct FloatingIslandView: View {
    let level: Level
    let isSelected: Bool
    let isUnlocked: Bool
    let stars: Int
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
                        // 浮岛主体
            ZStack {
                // 阴影层
                RoundedRectangle(cornerRadius: 30)
                    .fill(.black.opacity(0.3))
                    .frame(width: isSelected ? 280 : 220, height: isSelected ? 180 : 140)
                    .offset(x: 5, y: 10)

                // 浮岛底图 - 使用渐变色
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: getIslandColors(levelId: level.id),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: isSelected ? 280 : 220, height: isSelected ? 180 : 140)
                    .rotation3DEffect(
                        .degrees(15),
                        axis: (x: 1, y: 0, z: 0)
                    )
                    .shadow(
                        color: .black.opacity(isSelected ? 0.4 : 0.2),
                        radius: isSelected ? 20 : 10,
                        x: 0,
                        y: isSelected ? 15 : 8
                    )
                
                // 关卡信息覆盖层
                VStack(spacing: 8) {
                    // 关卡编号
                    Text("\(level.id)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.7), radius: 2)
                    
                    // 关卡标题
                    Text(level.title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.7), radius: 1)
                    
                    // 星级显示
                    if isUnlocked && stars > 0 {
                        HStack(spacing: 2) {
                            ForEach(0..<3) { index in
                                Image(systemName: index < stars ? "star.fill" : "star")
                                    .font(.caption2)
                                    .foregroundColor(index < stars ? .yellow : .gray)
                            }
                        }
                    }
                }
                
                // 锁定状态覆盖
                if !isUnlocked {
                    Rectangle()
                        .fill(.black.opacity(0.6))
                        .frame(width: isSelected ? 280 : 220, height: 150)
                        .overlay(
                            Image(systemName: "lock.fill")
                                .font(.title)
                                .foregroundColor(.gray)
                        )
                }
            }
            .onTapGesture {
                onTap()
            }
            
            // 开始游戏按钮(仅选中且解锁时显示)
            if isSelected && isUnlocked {
                NavigationLink(destination: GameView(level: level)) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("开始挑战")
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isSelected)
        .scaleEffect(isSelected ? 1.1 : 1.0)
    }
    
    /**
     * 根据关卡ID获取浮岛颜色
     * @param levelId 关卡ID
     * @return 渐变色数组
     */
    private func getIslandColors(levelId: Int) -> [Color] {
        let colorSets: [[Color]] = [
            [.blue, .cyan],      // 关卡1
            [.green, .mint],     // 关卡2
            [.orange, .yellow],  // 关卡3
            [.purple, .pink],    // 关卡4
            [.red, .orange],     // 关卡5
            [.teal, .blue],      // 关卡6
            [.indigo, .purple],  // 关卡7
            [.brown, .orange],   // 关卡8
        ]
        
        let index = (levelId - 1) % colorSets.count
        return colorSets[index]
    }
}

/**
 * 预览支持
 */
#Preview {
    LevelMapView()
}