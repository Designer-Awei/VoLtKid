/**
 * 关卡数据模型
 * 定义关卡的基本信息、六边形网格大小、电路元件配置等
 */
import Foundation

/**
 * 关卡配置数据结构
 */
struct Level: Codable, Identifiable {
    /// 关卡唯一标识
    let id: Int
    
    /// 关卡名称
    let title: String
    
    /// 星级评价(1-3)
    let star: Int
    
    /// 浮岛在地图中的偏移位置 [x, y]
    let floatOffset: [CGFloat]
    
    /// 六边形网格半径大小
    let size: Int
    
    /// 电路元件配置列表
    let components: [ComponentData]
    
    /// 玩家起始位置(六边形坐标)
    let startPos: AxialCoordinate
}

/**
 * 电路元件数据结构
 */
struct ComponentData: Codable {
    /// 元件类型(battery, bulb, switch等)
    let type: String
    
    /// 六边形网格q坐标
    let q: Int
    
    /// 六边形网格r坐标
    let r: Int
}

/**
 * 六边形轴向坐标系统
 * 使用(q,r)坐标表示六边形网格位置
 */
struct AxialCoordinate: Codable {
    let q: Int
    let r: Int
}

/**
 * 电路元件类型枚举
 */
enum ComponentType: String, CaseIterable {
    case battery = "battery"      // 电池
    case bulb = "bulb"           // 灯泡
    case `switch` = "switch"     // 开关(使用反引号转义关键字)
    case connector = "connector" // 连接器
    
    /**
     * 获取元件的中文显示名称
     */
    var displayName: String {
        switch self {
        case .battery: return "电池"
        case .bulb: return "灯泡"
        case .`switch`: return "开关"
        case .connector: return "连接器"
        }
    }
    
    /**
     * 获取对应的素材文件名
     */
    var assetName: String {
        return "游戏场景_\(displayName)元件"
    }
}
