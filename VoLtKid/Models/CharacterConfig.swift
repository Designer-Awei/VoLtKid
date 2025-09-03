/**
 * 角色配置
 * 统一管理角色的名称、图标、颜色等属性
 */
import SwiftUI

/**
 * 角色数据结构
 */
struct Character {
    let id: Int
    let name: String
    let description: String
    let specialty: String
    let icon: String
    let colors: [Color]
}

/**
 * 全局角色配置
 */
struct CharacterConfig {
    /// 所有可用角色
    static let characters: [Character] = [
        Character(
            id: 0,
            name: "电路探险家",
            description: "勇敢的先锋，擅长快速连接电路元件",
            specialty: "快速移动",
            icon: "bolt.circle.fill",
            colors: [.orange, .red]
        ),
        Character(
            id: 1,
            name: "电学工程师",
            description: "智慧的学者，能发现最优的电路路径",
            specialty: "路径优化",
            icon: "lightbulb.circle.fill",
            colors: [.blue, .purple]
        ),
        Character(
            id: 2,
            name: "电子小精灵",
            description: "活泼的助手，拥有特殊的跳跃能力",
            specialty: "跳跃移动",
            icon: "star.circle.fill",
            colors: [.green, .teal]
        ),
        Character(
            id: 3,
            name: "治愈师",
            description: "温柔的守护者，能修复损坏的电路",
            specialty: "电路修复",
            icon: "heart.circle.fill",
            colors: [.pink, .purple]
        ),
        Character(
            id: 4,
            name: "电路法师",
            description: "神秘的魔法师，掌握高级电路魔法",
            specialty: "魔法连接",
            icon: "diamond.circle.fill",
            colors: [.indigo, .blue]
        )
    ]
    
    /**
     * 根据索引获取角色
     */
    static func getCharacter(at index: Int) -> Character {
        guard index >= 0 && index < characters.count else {
            return Character(
                id: -1,
                name: "未知角色",
                description: "神秘的角色",
                specialty: "未知",
                icon: "questionmark.circle.fill",
                colors: [.gray, .black]
            )
        }
        return characters[index]
    }
    
    /**
     * 获取角色名称
     */
    static func getCharacterName(at index: Int) -> String {
        return getCharacter(at: index).name
    }
    
    /**
     * 获取角色图标
     */
    static func getCharacterIcon(at index: Int) -> String {
        return getCharacter(at: index).icon
    }
    
    /**
     * 获取角色颜色
     */
    static func getCharacterColors(at index: Int) -> [Color] {
        return getCharacter(at: index).colors
    }
    
    /**
     * 获取角色描述
     */
    static func getCharacterDescription(at index: Int) -> String {
        return getCharacter(at: index).description
    }
    
    /**
     * 获取角色特长
     */
    static func getCharacterSpecialty(at index: Int) -> String {
        return getCharacter(at: index).specialty
    }
}
