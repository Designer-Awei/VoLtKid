/**
 * 全局游戏状态管理
 * 负责管理角色选择、关卡进度等全局状态
 */
import Foundation

final class GameState: ObservableObject {
    /// 单例实例
    static let shared = GameState()
    
    /// 当前选择的角色索引
    @Published var selectedHeroIndex = 0
    
    /// 已解锁的关卡编号
    @Published var unlockedLevel = 1
    
    /// 当前关卡的星级评价
    @Published var levelStars: [Int: Int] = [:]
    
    /// 私有初始化，确保单例模式
    private init() {
        loadGameProgress()
    }
    
    /**
     * 保存游戏进度到UserDefaults
     */
    func saveGameProgress() {
        UserDefaults.standard.set(selectedHeroIndex, forKey: "selectedHeroIndex")
        UserDefaults.standard.set(unlockedLevel, forKey: "unlockedLevel")
        UserDefaults.standard.set(levelStars, forKey: "levelStars")
    }
    
    /**
     * 从UserDefaults加载游戏进度
     */
    private func loadGameProgress() {
        selectedHeroIndex = UserDefaults.standard.integer(forKey: "selectedHeroIndex")
        unlockedLevel = max(1, UserDefaults.standard.integer(forKey: "unlockedLevel"))
        levelStars = UserDefaults.standard.dictionary(forKey: "levelStars") as? [Int: Int] ?? [:]
    }
    
    /**
     * 完成关卡，更新进度和星级
     * @param levelId 关卡ID
     * @param stars 获得的星级(1-3)
     */
    func completeLevel(_ levelId: Int, stars: Int) {
        levelStars[levelId] = max(levelStars[levelId] ?? 0, stars)
        unlockedLevel = max(unlockedLevel, levelId + 1)
        saveGameProgress()
    }
    
    /**
     * 检查关卡是否已解锁
     * @param levelId 关卡ID
     * @return 是否已解锁
     */
    func isLevelUnlocked(_ levelId: Int) -> Bool {
        return levelId <= unlockedLevel
    }
}
