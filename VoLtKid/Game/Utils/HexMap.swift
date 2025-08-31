/**
 * 六边形网格系统工具类
 * 提供六边形坐标转换、路径查找等核心功能
 */
import Foundation
import SpriteKit

/**
 * 六边形地图管理器
 */
struct HexMap {
    /// 六边形基础尺寸(像素)
    let hexSize: CGFloat
    
    /// 网格中心偏移量
    let centerOffset: CGPoint
    
    /**
     * 初始化六边形地图
     * @param hexSize 六边形大小
     * @param centerOffset 中心偏移
     */
    init(hexSize: CGFloat = 40, centerOffset: CGPoint = .zero) {
        self.hexSize = hexSize
        self.centerOffset = centerOffset
    }
    
    /**
     * 将六边形坐标转换为像素坐标
     * @param axial 六边形轴向坐标
     * @return 对应的像素坐标
     */
    func pixelPosition(for axial: AxialCoordinate) -> CGPoint {
        let x = hexSize * (3.0/2.0 * CGFloat(axial.q))
        
        // 拆分y坐标计算以避免编译器类型检查超时
        let qComponent = sqrt(3.0)/2.0 * CGFloat(axial.q)
        let rComponent = sqrt(3.0) * CGFloat(axial.r)
        let y = hexSize * (qComponent + rComponent)
        
        return CGPoint(
            x: x + centerOffset.x,
            y: y + centerOffset.y
        )
    }
    
    /**
     * 将像素坐标转换为六边形坐标
     * @param point 像素坐标
     * @return 对应的六边形坐标
     */
    func axialCoordinate(for point: CGPoint) -> AxialCoordinate {
        let adjustedPoint = CGPoint(
            x: point.x - centerOffset.x,
            y: point.y - centerOffset.y
        )
        
        let q = (2.0/3.0 * adjustedPoint.x) / hexSize
        let r = (-1.0/3.0 * adjustedPoint.x + sqrt(3.0)/3.0 * adjustedPoint.y) / hexSize
        
        return roundToHex(q: q, r: r)
    }
    
    /**
     * 获取六边形的所有邻居坐标
     * @param axial 中心六边形坐标
     * @return 6个邻居坐标数组
     */
    func neighbors(of axial: AxialCoordinate) -> [AxialCoordinate] {
        let directions = [
            (1, 0), (1, -1), (0, -1),
            (-1, 0), (-1, 1), (0, 1)
        ]
        
        return directions.map { (dq, dr) in
            AxialCoordinate(q: axial.q + dq, r: axial.r + dr)
        }
    }
    
    /**
     * 计算两个六边形坐标之间的距离
     * @param from 起始坐标
     * @param to 目标坐标
     * @return 网格距离
     */
    func distance(from: AxialCoordinate, to: AxialCoordinate) -> Int {
        let dq = abs(from.q - to.q)
        let dr = abs(from.r - to.r)
        let ds = abs(from.q + from.r - to.q - to.r)
        
        return max(dq, dr, ds)
    }
    
    /**
     * 使用A*算法查找最短路径
     * @param from 起始坐标
     * @param to 目标坐标
     * @param obstacles 障碍物坐标集合
     * @return 路径坐标数组
     */
    func findPath(from: AxialCoordinate, to: AxialCoordinate, obstacles: Set<AxialCoordinate> = []) -> [AxialCoordinate] {
        
        // 简单直线路径实现(可扩展为完整A*算法)
        if obstacles.isEmpty {
            return linearInterpolation(from: from, to: to)
        }
        
        // TODO: 实现完整的A*寻路算法
        return linearInterpolation(from: from, to: to)
    }
    
    /**
     * 检查坐标是否在指定半径范围内
     * @param coordinate 待检查坐标
     * @param center 中心坐标
     * @param radius 半径
     * @return 是否在范围内
     */
    func isInRange(_ coordinate: AxialCoordinate, center: AxialCoordinate, radius: Int) -> Bool {
        return distance(from: coordinate, to: center) <= radius
    }
    
    /**
     * 获取指定半径范围内的所有坐标
     * @param center 中心坐标
     * @param radius 半径
     * @return 范围内坐标数组
     */
    func coordinatesInRange(center: AxialCoordinate, radius: Int) -> [AxialCoordinate] {
        var coordinates: [AxialCoordinate] = []
        
        for q in -radius...radius {
            let r1 = max(-radius, -q - radius)
            let r2 = min(radius, -q + radius)
            
            for r in r1...r2 {
                coordinates.append(AxialCoordinate(q: center.q + q, r: center.r + r))
            }
        }
        
        return coordinates
    }
    
    // MARK: - Private Methods
    
    /**
     * 将浮点坐标四舍五入到最近的六边形坐标
     * @param q 浮点q坐标
     * @param r 浮点r坐标
     * @return 四舍五入后的六边形坐标
     */
    private func roundToHex(q: CGFloat, r: CGFloat) -> AxialCoordinate {
        let s = -q - r
        
        var roundedQ = round(q)
        var roundedR = round(r)
        var roundedS = round(s)
        
        let qDiff = abs(roundedQ - q)
        let rDiff = abs(roundedR - r)
        let sDiff = abs(roundedS - s)
        
        if qDiff > rDiff && qDiff > sDiff {
            roundedQ = -roundedR - roundedS
        } else if rDiff > sDiff {
            roundedR = -roundedQ - roundedS
        }
        
        return AxialCoordinate(q: Int(roundedQ), r: Int(roundedR))
    }
    
    /**
     * 线性插值生成直线路径
     * @param from 起始坐标
     * @param to 目标坐标
     * @return 插值路径
     */
    private func linearInterpolation(from: AxialCoordinate, to: AxialCoordinate) -> [AxialCoordinate] {
        let distance = self.distance(from: from, to: to)
        var path: [AxialCoordinate] = []
        
        for i in 0...distance {
            let t = distance == 0 ? 0.0 : CGFloat(i) / CGFloat(distance)
            
            let q = CGFloat(from.q) + t * CGFloat(to.q - from.q)
            let r = CGFloat(from.r) + t * CGFloat(to.r - from.r)
            
            path.append(roundToHex(q: q, r: r))
        }
        
        return path
    }
}

/**
 * 六边形坐标扩展
 */
extension AxialCoordinate: Hashable, Equatable {
    static func == (lhs: AxialCoordinate, rhs: AxialCoordinate) -> Bool {
        return lhs.q == rhs.q && lhs.r == rhs.r
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(q)
        hasher.combine(r)
    }
}

/**
 * 六边形坐标便利初始化
 */
extension AxialCoordinate {
    /**
     * 从元组创建坐标
     */
    init(_ tuple: (Int, Int)) {
        self.init(q: tuple.0, r: tuple.1)
    }
    
    /**
     * 转换为元组
     */
    var tuple: (Int, Int) {
        return (q, r)
    }
}
