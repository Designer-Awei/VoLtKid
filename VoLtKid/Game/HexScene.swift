/**
 * 六边形游戏场景
 * 基于SpriteKit实现的核心游戏逻辑
 */
import SpriteKit
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/**
 * 六边形游戏场景类
 */
class HexScene: SKScene {
    // MARK: - 属性
    
    /// 当前关卡数据
    private let level: Level
    
    /// 六边形网格管理器
    private var hexMap: HexMap!
    
    /// 玩家角色节点
    private var playerNode: SKSpriteNode!
    
    /// 电路元件节点字典
    private var componentNodes: [AxialCoordinate: SKSpriteNode] = [:]
    
    /// 六边形网格节点字典
    private var hexTiles: [AxialCoordinate: SKSpriteNode] = [:]
    
    /// 已激活的电路路径
    private var activatedPath: [AxialCoordinate] = []
    
    /// 玩家当前位置
    private var playerPosition: AxialCoordinate
    
    /// 游戏状态
    private var gameState: GameStatus = .playing
    
    /// 连线模式状态
    private var isInConnectMode = false
    
    // MARK: - 回调闭包
    
    /// 游戏完成回调
    var onGameComplete: ((Int) -> Void)?
    
    /// 游戏状态变化回调
    var onGameStatusChange: ((GameStatus) -> Void)?
    
    // MARK: - 初始化
    
    /**
     * 初始化游戏场景
     * @param level 关卡数据
     */
    init(level: Level) {
        self.level = level
        self.playerPosition = level.startPos
        super.init(size: .zero)
        
        setupScene()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 场景设置
    
    /**
     * 场景移动到视图时调用
     */
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // 设置六边形网格管理器
        hexMap = HexMap(
            hexSize: 35,
            centerOffset: CGPoint(x: size.width/2, y: size.height/2)
        )
        
        setupBackground()
        setupHexGrid()
        setupComponents()
        setupPlayer()
    }
    
    /**
     * 设置场景基础属性
     */
    private func setupScene() {
        backgroundColor = SKColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 1.0)
        scaleMode = .resizeFill
    }
    
    /**
     * 设置背景
     */
    private func setupBackground() {
        // 可以添加星空背景或其他装饰
        let backgroundGradient = SKSpriteNode(color: SKColor(red: 0.05, green: 0.15, blue: 0.35, alpha: 1.0), size: size)
        backgroundGradient.position = CGPoint(x: size.width/2, y: size.height/2)
        backgroundGradient.zPosition = -100
        addChild(backgroundGradient)
    }
    
    /**
     * 设置六边形网格
     */
    private func setupHexGrid() {
        let gridCoordinates = hexMap.coordinatesInRange(
            center: AxialCoordinate(q: 0, r: 0),
            radius: level.size
        )
        
        for coordinate in gridCoordinates {
            let hexTile = createHexTile(at: coordinate)
            hexTiles[coordinate] = hexTile
            addChild(hexTile)
        }
    }
    
    /**
     * 创建六边形瓦片
     * @param coordinate 六边形坐标
     * @return 瓦片节点
     */
    private func createHexTile(at coordinate: AxialCoordinate) -> SKSpriteNode {
        let position = hexMap.pixelPosition(for: coordinate)
        
        // 创建六边形形状
        let hexShape = SKShapeNode()
        let path = createHexagonPath(radius: hexMap.hexSize * 0.9)
        hexShape.path = path
        hexShape.fillColor = SKColor(white: 0.2, alpha: 0.3)
        hexShape.strokeColor = SKColor(white: 0.4, alpha: 0.6)
        hexShape.lineWidth = 1.5
        
        // 包装在SKSpriteNode中以便于管理
        let tileNode = SKSpriteNode()
        tileNode.position = position
        tileNode.addChild(hexShape)
        tileNode.name = "hex_\(coordinate.q)_\(coordinate.r)"
        tileNode.zPosition = 0
        
        return tileNode
    }
    
    /**
     * 创建六边形路径
     * @param radius 六边形半径
     * @return 六边形CGPath
     */
    private func createHexagonPath(radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        
        for i in 0..<6 {
            let angle = CGFloat(i) * CGFloat.pi / 3.0
            let x = radius * cos(angle)
            let y = radius * sin(angle)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
    
    /**
     * 设置电路元件
     */
    private func setupComponents() {
        for component in level.components {
            let coordinate = AxialCoordinate(q: component.q, r: component.r)
            let componentNode = createComponentNode(component: component, at: coordinate)
            componentNodes[coordinate] = componentNode
            addChild(componentNode)
        }
    }
    
    /**
     * 创建电路元件节点
     * @param component 元件数据
     * @param coordinate 位置坐标
     * @return 元件节点
     */
    private func createComponentNode(component: ComponentData, at coordinate: AxialCoordinate) -> SKSpriteNode {
        let position = hexMap.pixelPosition(for: coordinate)
        
        // 使用颜色创建元件占位
        let componentColor = getComponentColor(type: component.type)
        let componentNode = SKSpriteNode(color: componentColor, size: CGSize(width: 50, height: 50))
        componentNode.position = position
        componentNode.name = "component_\(component.type)_\(coordinate.q)_\(coordinate.r)"
        componentNode.zPosition = 2
        
        // 添加形状和图标
        let shapeNode = createComponentShape(type: component.type)
        shapeNode.position = CGPoint.zero
        componentNode.addChild(shapeNode)
        
        // 添加发光效果(未激活状态)
        componentNode.alpha = 0.7
        
        return componentNode
    }
    
    /**
     * 设置玩家角色
     */
    private func setupPlayer() {
        let position = hexMap.pixelPosition(for: playerPosition)
        
        // 使用颜色和形状创建玩家占位
        let gameState = GameState.shared
        let playerColor = getPlayerColor(heroIndex: gameState.selectedHeroIndex)
        
        playerNode = SKSpriteNode(color: playerColor, size: CGSize(width: 60, height: 60))
        playerNode.position = position
        playerNode.name = "player"
        playerNode.zPosition = 10
        
        // 添加玩家图标
        let playerShape = createPlayerShape(heroIndex: gameState.selectedHeroIndex)
        playerShape.position = CGPoint.zero
        playerNode.addChild(playerShape)
        
        // 添加选择指示器
        let selectionRing = SKShapeNode(circleOfRadius: 35)
        selectionRing.strokeColor = .green
        selectionRing.lineWidth = 3
        selectionRing.alpha = 0
        selectionRing.name = "selection_ring"
        playerNode.addChild(selectionRing)
        
        addChild(playerNode)
    }
    
    // MARK: - 输入处理
    
    #if canImport(UIKit)
    /**
     * 处理触摸事件 (iOS)
     */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        handleInput(at: location)
    }
    #elseif canImport(AppKit)
    /**
     * 处理鼠标点击事件 (macOS)
     */
    override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        handleInput(at: location)
    }
    #endif
    
    /**
     * 统一的输入处理方法
     * @param location 输入位置
     */
    private func handleInput(at location: CGPoint) {
        let touchedNode = atPoint(location)
        
        // 处理玩家角色点击
        if touchedNode.name == "player" || touchedNode.parent?.name == "player" {
            toggleConnectMode()
            return
        }
        
        // 处理六边形网格点击
        let touchedCoordinate = hexMap.axialCoordinate(for: location)
        
        if isInConnectMode && hexMap.isInRange(touchedCoordinate, center: AxialCoordinate(q: 0, r: 0), radius: level.size) {
            movePlayerTo(coordinate: touchedCoordinate)
        }
    }
    
    /**
     * 切换连线模式
     */
    private func toggleConnectMode() {
        isInConnectMode.toggle()
        
        if let selectionRing = playerNode.childNode(withName: "selection_ring") {
            let fadeAction = SKAction.fadeAlpha(to: isInConnectMode ? 1.0 : 0.0, duration: 0.3)
            selectionRing.run(fadeAction)
        }
        
        gameState = isInConnectMode ? .connecting : .playing
        onGameStatusChange?(gameState)
    }
    
    /**
     * 移动玩家到指定坐标
     * @param coordinate 目标坐标
     */
    private func movePlayerTo(coordinate: AxialCoordinate) {
        guard isInConnectMode else { return }
        
        let path = hexMap.findPath(from: playerPosition, to: coordinate)
        guard path.count > 1 else { return }
        
        // 创建移动动画
        var moveActions: [SKAction] = []
        
        for (index, coord) in path.enumerated() {
            if index == 0 { continue } // 跳过起始位置
            
            let position = hexMap.pixelPosition(for: coord)
            let moveAction = SKAction.move(to: position, duration: 0.25)
            moveActions.append(moveAction)
        }
        
        let sequence = SKAction.sequence(moveActions)
        let completion = SKAction.run { [weak self] in
            self?.handlePlayerArrival(at: coordinate, path: path)
        }
        
        playerNode.run(SKAction.sequence([sequence, completion]))
        
        // 绘制移动轨迹
        drawPath(path)
    }
    
    /**
     * 处理玩家到达目标位置
     * @param coordinate 到达的坐标
     * @param path 移动路径
     */
    private func handlePlayerArrival(at coordinate: AxialCoordinate, path: [AxialCoordinate]) {
        playerPosition = coordinate
        
        // 激活经过的元件
        for coord in path {
            if let componentNode = componentNodes[coord] {
                activateComponent(node: componentNode, at: coord)
            }
        }
        
        // 添加到激活路径
        activatedPath.append(contentsOf: path.dropFirst())
        
        // 检查胜利条件
        checkVictoryCondition()
        
        // 退出连线模式
        toggleConnectMode()
    }
    
    /**
     * 激活电路元件
     * @param node 元件节点
     * @param coordinate 坐标
     */
    private func activateComponent(node: SKSpriteNode, at coordinate: AxialCoordinate) {
        // 高亮显示
        node.alpha = 1.0
        node.color = .yellow
        node.colorBlendFactor = 0.3
        
        // 添加发光动画
        let glowAction = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ])
        node.run(glowAction)
    }
    
    /**
     * 绘制移动路径
     * @param path 路径坐标数组
     */
    private func drawPath(_ path: [AxialCoordinate]) {
        guard path.count > 1 else { return }
        
        let pathNode = SKShapeNode()
        let pathCGPath = CGMutablePath()
        
        for (index, coordinate) in path.enumerated() {
            let position = hexMap.pixelPosition(for: coordinate)
            
            if index == 0 {
                pathCGPath.move(to: position)
            } else {
                pathCGPath.addLine(to: position)
            }
        }
        
        pathNode.path = pathCGPath
        pathNode.strokeColor = .cyan
        pathNode.lineWidth = 4
        pathNode.alpha = 0.8
        pathNode.zPosition = 1
        pathNode.name = "path_line"
        
        addChild(pathNode)
        
        // 路径动画效果
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 1.0)
        pathNode.run(fadeOut)
    }
    
    /**
     * 检查胜利条件
     */
    private func checkVictoryCondition() {
        // 简单胜利条件：激活所有元件且形成闭合回路
        let totalComponents = level.components.count
        let activatedComponents = componentNodes.values.filter { $0.alpha == 1.0 }.count
        
        if activatedComponents >= totalComponents && activatedPath.count > 2 {
            // 检查是否形成闭合回路
            if let firstCoord = activatedPath.first, let lastCoord = activatedPath.last {
                let distance = hexMap.distance(from: firstCoord, to: lastCoord)
                if distance <= 1 { // 相邻或相同位置认为闭合
                    handleVictory()
                }
            }
        }
    }
    
    /**
     * 处理胜利
     */
    private func handleVictory() {
        gameState = .completed
        
        // 计算星级(基于步数或其他因素)
        let stars = calculateStars()
        
        // 胜利特效
        playVictoryEffects()
        
        // 延迟调用完成回调
        let delay = SKAction.wait(forDuration: 1.5)
        let completion = SKAction.run { [weak self] in
            self?.onGameComplete?(stars)
        }
        run(SKAction.sequence([delay, completion]))
    }
    
    /**
     * 计算星级评价
     * @return 星级(1-3)
     */
    private func calculateStars() -> Int {
        // 基于移动步数计算星级
        let optimalSteps = level.components.count + 1
        let actualSteps = activatedPath.count
        
        if actualSteps <= optimalSteps {
            return 3
        } else if actualSteps <= Int(Double(optimalSteps) * 1.5) {
            return 2
        } else {
            return 1
        }
    }
    
    /**
     * 播放胜利特效
     */
    private func playVictoryEffects() {
        // 所有激活元件闪烁
        for node in componentNodes.values where node.alpha == 1.0 {
            let blink = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: 0.2),
                SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            ])
            let repeatAction = SKAction.repeat(blink, count: 5)
            node.run(repeatAction)
        }
        
        // 玩家角色庆祝动画
        let celebrate = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        playerNode.run(SKAction.repeat(celebrate, count: 3))
    }
    
    // MARK: - 公共方法
    
    /**
     * 显示提示
     */
    func showHint() {
        // TODO: 实现提示功能
        // 可以高亮显示下一个应该连接的元件
    }
    
    /**
     * 撤销上一步移动
     */
    func undoLastMove() {
        // TODO: 实现撤销功能
        // 保存移动历史，允许撤销操作
    }
    
    // MARK: - 原生UI辅助函数
    
    /**
     * 获取组件对应的颜色
     * @param type 组件类型
     * @return SKColor颜色
     */
    private func getComponentColor(type: String) -> SKColor {
        switch type {
        case "battery":
            return SKColor.systemGreen
        case "bulb":
            return SKColor.systemYellow
        case "switch":
            return SKColor.systemOrange
        case "connector":
            return SKColor.systemBlue
        default:
            return SKColor.systemGray
        }
    }
    
    /**
     * 创建组件形状
     * @param type 组件类型
     * @return SKShapeNode形状节点
     */
    private func createComponentShape(type: String) -> SKShapeNode {
        let shapeNode: SKShapeNode
        
        switch type {
        case "battery":
            // 电池 - 矩形
            shapeNode = SKShapeNode(rectOf: CGSize(width: 30, height: 40))
            shapeNode.fillColor = .white
            shapeNode.strokeColor = .black
            shapeNode.lineWidth = 2
            
        case "bulb":
            // 灯泡 - 圆形
            shapeNode = SKShapeNode(circleOfRadius: 18)
            shapeNode.fillColor = .white
            shapeNode.strokeColor = .black
            shapeNode.lineWidth = 2
            
        case "switch":
            // 开关 - 圆角矩形
            shapeNode = SKShapeNode(rectOf: CGSize(width: 35, height: 25), cornerRadius: 8)
            shapeNode.fillColor = .white
            shapeNode.strokeColor = .black
            shapeNode.lineWidth = 2
            
        case "connector":
            // 连接器 - 菱形
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 20))
            path.addLine(to: CGPoint(x: 15, y: 0))
            path.addLine(to: CGPoint(x: 0, y: -20))
            path.addLine(to: CGPoint(x: -15, y: 0))
            path.closeSubpath()
            
            shapeNode = SKShapeNode(path: path)
            shapeNode.fillColor = .white
            shapeNode.strokeColor = .black
            shapeNode.lineWidth = 2
            
        default:
            shapeNode = SKShapeNode(circleOfRadius: 15)
            shapeNode.fillColor = .gray
            shapeNode.strokeColor = .black
            shapeNode.lineWidth = 2
        }
        
        return shapeNode
    }
    
    /**
     * 获取玩家对应的颜色
     * @param heroIndex 角色索引
     * @return SKColor颜色
     */
    private func getPlayerColor(heroIndex: Int) -> SKColor {
        switch heroIndex {
        case 0:
            return SKColor.systemRed
        case 1:
            return SKColor.systemBlue
        case 2:
            return SKColor.systemPurple
        default:
            return SKColor.systemGray
        }
    }
    
    /**
     * 创建玩家形状
     * @param heroIndex 角色索引
     * @return SKShapeNode形状节点
     */
    private func createPlayerShape(heroIndex: Int) -> SKShapeNode {
        let shapeNode = SKShapeNode(circleOfRadius: 25)
        shapeNode.fillColor = .white
        shapeNode.strokeColor = .black
        shapeNode.lineWidth = 3
        
        // 添加角色标识
        let label = SKLabelNode(text: "\(heroIndex + 1)")
        label.fontName = "Arial-Bold"
        label.fontSize = 24
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        shapeNode.addChild(label)
        
        return shapeNode
    }
}
