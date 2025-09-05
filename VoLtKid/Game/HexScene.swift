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
    
    /// 移动历史记录
    private var moveHistory: [(position: AxialCoordinate, activatedComponents: Set<AxialCoordinate>)] = []
    
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

        // 创建透明背景的元件节点
        let componentNode = SKSpriteNode(color: .clear, size: CGSize(width: 50, height: 50))
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

        // 创建透明背景的玩家节点
        playerNode = SKSpriteNode(color: .clear, size: CGSize(width: 60, height: 60))
        playerNode.position = position
        playerNode.name = "player"
        playerNode.zPosition = 10

        // 添加玩家图标
        let gameState = GameState.shared
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
        // 保存当前状态到历史记录
        let currentActivatedComponents = Set(getActivatedComponents().keys)
        moveHistory.append((position: playerPosition, activatedComponents: currentActivatedComponents))
        
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
        print("🎮 开始检查电路胜利条件...")
        
        // 1. 必须激活所有元件
        let activatedComponents = getActivatedComponents()
        let totalComponents = level.components.count
        print("📊 已激活元件: \(activatedComponents.count)/\(totalComponents)")
        
        if activatedComponents.count < totalComponents {
            print("❌ 还有 \(totalComponents - activatedComponents.count) 个元件未激活")
            return
        }
        
        // 2. 必须有电池
        guard let batteryCoord = findBattery(in: activatedComponents) else {
            print("❌ 没有找到激活的电池")
            return
        }
        
        // 3. 必须有灯泡
        let bulbs = findBulbs(in: activatedComponents)
        if bulbs.isEmpty {
            print("❌ 没有找到激活的灯泡")
            return
        }
        
        // 4. 检查是否形成闭合回路
        if !hasClosedCircuit(battery: batteryCoord, bulbs: bulbs, components: activatedComponents) {
            print("❌ 没有形成闭合的电路回路")
            return
        }
        
        print("🎉 形成了完整的闭合电路！胜利！")
        handleVictory()
    }
    
    /**
     * 处理胜利
     */
    private func handleVictory() {
        print("🏆 处理胜利逻辑...")
        gameState = .completed
        onGameStatusChange?(gameState)
        
        // 计算星级(基于步数或其他因素)
        let stars = calculateStars()
        print("⭐ 获得星级: \(stars)")
        
        // 胜利特效
        playVictoryEffects()
        
        // 延迟调用完成回调
        let delay = SKAction.wait(forDuration: 1.5)
        let completion = SKAction.run { [weak self] in
            print("🎯 触发游戏完成回调...")
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
        print("💡 显示提示")
        
        // 找到下一个应该连接的元件
        let activatedComponents = getActivatedComponents()
        let allComponents = level.components
        
        // 找到第一个未激活的元件
        for component in allComponents {
            let coord = AxialCoordinate(q: component.q, r: component.r)
            if !activatedComponents.keys.contains(coord) {
                // 高亮显示这个元件
                if let componentNode = componentNodes[coord] {
                    highlightComponent(componentNode)
                }
                break
            }
        }
    }
    
    /**
     * 撤销上一步移动
     */
    func undoLastMove() {
        print("↩️ 撤销上一步移动")
        
        guard !moveHistory.isEmpty else {
            print("❌ 没有可撤销的移动")
            return
        }
        
        // 获取上一个状态
        let lastState = moveHistory.removeLast()
        let lastPosition = lastState.position
        let lastActivatedComponents = lastState.activatedComponents
        
        // 恢复玩家位置
        playerPosition = lastPosition
        let newPosition = hexMap.pixelPosition(for: lastPosition)
        playerNode.position = newPosition
        
        // 重置所有组件状态
        for (coord, node) in componentNodes {
            if lastActivatedComponents.contains(coord) {
                // 恢复激活状态
                node.alpha = 1.0
                node.color = .yellow
                node.colorBlendFactor = 0.3
            } else {
                // 恢复未激活状态
                node.alpha = 0.7
                node.color = getComponentColor(type: getComponentType(at: coord))
                node.colorBlendFactor = 0.0
            }
        }
        
        // 更新激活路径
        activatedPath = Array(lastActivatedComponents)
        
        // 移除多余的路径线
        children.forEach { child in
            if child.name == "path_line" {
                child.removeFromParent()
            }
        }
        
        print("✅ 撤销完成，回到位置: \(lastPosition)")
    }
    
    /**
     * 更新玩家角色外观
     */
    func updatePlayerCharacter() {
        guard let playerNode = playerNode else { return }
        
        let gameState = GameState.shared
        let newColor = getPlayerColor(heroIndex: gameState.selectedHeroIndex)
        
        // 更新玩家节点颜色
        playerNode.color = newColor
        
        // 移除旧的形状节点
        playerNode.children.forEach { child in
            if let shapeNode = child as? SKShapeNode, child.name != "selection_ring" {
                child.removeFromParent()
            }
        }
        
        // 添加新的玩家形状
        let newPlayerShape = createPlayerShape(heroIndex: gameState.selectedHeroIndex)
        newPlayerShape.position = CGPoint.zero
        playerNode.addChild(newPlayerShape)
    }
    
    /**
     * 高亮显示组件
     */
    private func highlightComponent(_ componentNode: SKSpriteNode) {
        // 移除之前的高亮效果
        componentNode.removeAction(forKey: "hint_highlight")
        
        // 创建高亮动画
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let highlight = SKAction.sequence([scaleUp, scaleDown])
        let repeat3Times = SKAction.repeat(highlight, count: 3)
        
        componentNode.run(repeat3Times, withKey: "hint_highlight")
    }
    
    /**
     * 获取指定坐标的组件类型
     */
    private func getComponentType(at coordinate: AxialCoordinate) -> String {
        for component in level.components {
            if AxialCoordinate(q: component.q, r: component.r) == coordinate {
                return component.type
            }
        }
        return "unknown"
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
        // 所有组件都使用六边形边框，不填充背景
        let shapeNode = SKShapeNode(path: createHexagonPath(radius: 25))
        shapeNode.fillColor = .clear  // 移除白色填充背景
        shapeNode.strokeColor = .black
        shapeNode.lineWidth = 2

        return shapeNode
    }
    
    /**
     * 获取玩家对应的颜色
     * @param heroIndex 角色索引
     * @return SKColor颜色
     */
    private func getPlayerColor(heroIndex: Int) -> SKColor {
        let colors = CharacterConfig.getCharacterColors(at: heroIndex)
        let primaryColor = colors.first ?? .gray
        
        // 将SwiftUI Color转换为SKColor
        #if canImport(UIKit)
        return SKColor(primaryColor)
        #elseif canImport(AppKit)
        return SKColor(primaryColor)
        #else
        return SKColor.systemGray
        #endif
    }
    
    /**
     * 创建玩家形状
     * @param heroIndex 角色索引
     * @return SKShapeNode形状节点
     */
    private func createPlayerShape(heroIndex: Int) -> SKShapeNode {
        let shapeNode = SKShapeNode(circleOfRadius: 25)

        // 获取角色颜色
        let colors = CharacterConfig.getCharacterColors(at: heroIndex)
        let primaryColor = colors.first ?? .gray

        // 将SwiftUI Color转换为SKColor
        #if canImport(UIKit)
        shapeNode.fillColor = SKColor(primaryColor)
        #elseif canImport(AppKit)
        shapeNode.fillColor = SKColor(primaryColor)
        #else
        shapeNode.fillColor = SKColor.systemGray
        #endif

        shapeNode.strokeColor = .white
        shapeNode.lineWidth = 2

        // 使用角色图标
        let characterIcon = CharacterConfig.getCharacterIcon(at: heroIndex)

        // 创建图标标签 - 使用SF Symbol
        let label = SKLabelNode(text: getIconSymbol(for: characterIcon))
        label.fontName = "SF Pro Display"  // 支持SF Symbols的字体
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        shapeNode.addChild(label)

        return shapeNode
    }
    
    /**
     * 将图标名称转换为可显示的符号
     * @param iconName SF Symbol名称
     * @return 可显示的符号字符
     */
    private func getIconSymbol(for iconName: String) -> String {
        switch iconName {
        case "bolt.circle.fill":
            return "⚡"
        case "lightbulb.circle.fill":
            return "💡"
        case "star.circle.fill":
            return "⭐"
        case "heart.circle.fill":
            return "❤️"
        case "diamond.circle.fill":
            return "💎"
        default:
            return "?"
        }
    }
    
    // MARK: - 电路分析方法
    
    /**
     * 获取所有已激活的元件
     * @return 激活元件的坐标和类型字典
     */
    private func getActivatedComponents() -> [AxialCoordinate: String] {
        var activatedComponents: [AxialCoordinate: String] = [:]
        
        for (coord, node) in componentNodes {
            if node.alpha == 1.0 { // 已激活
                // 从关卡数据中找到对应的元件类型
                if let component = level.components.first(where: { 
                    AxialCoordinate(q: $0.q, r: $0.r) == coord 
                }) {
                    activatedComponents[coord] = component.type
                }
            }
        }
        
        return activatedComponents
    }
    
    /**
     * 在激活元件中查找电池
     * @param activatedComponents 已激活的元件
     * @return 电池坐标，如果没有则返回nil
     */
    private func findBattery(in activatedComponents: [AxialCoordinate: String]) -> AxialCoordinate? {
        return activatedComponents.first { $0.value == "battery" }?.key
    }
    
    /**
     * 在激活元件中查找所有灯泡
     * @param activatedComponents 已激活的元件
     * @return 灯泡坐标数组
     */
    private func findBulbs(in activatedComponents: [AxialCoordinate: String]) -> [AxialCoordinate] {
        return activatedComponents.compactMap { coord, type in
            type == "bulb" ? coord : nil
        }
    }
    
    /**
     * 检查是否形成闭合电路
     * @param battery 电池坐标
     * @param bulbs 灯泡坐标数组
     * @param components 激活的元件
     * @return 是否形成闭合回路
     */
    private func hasClosedCircuit(battery: AxialCoordinate, bulbs: [AxialCoordinate], components: [AxialCoordinate: String]) -> Bool {
        print("🔄 检查闭合回路: 电池\(battery) → 灯泡\(bulbs)")
        print("🛤️ 玩家路径: \(activatedPath)")
        
        // 检查玩家路径是否形成从电池出发又回到电池的闭合回路
        guard !activatedPath.isEmpty else {
            print("❌ 玩家没有移动，无法形成电路")
            return false
        }
        
        // 获取玩家的完整路径（包括起始位置）
        var fullPath = [playerPosition] // 当前位置
        fullPath.append(contentsOf: activatedPath)
        
        print("🚶 完整移动路径: \(fullPath)")
        
        // 检查路径是否经过所有元件
        for (coord, _) in components {
            if !fullPath.contains(coord) {
                print("❌ 路径没有经过元件: \(coord)")
                return false
            }
        }
        
        // 检查是否形成闭合回路（回到起始位置附近）
        let startPos = level.startPos
        let currentPos = playerPosition
        let distance = hexMap.distance(from: AxialCoordinate(q: startPos.q, r: startPos.r), to: currentPos)
        
        if distance <= 1 { // 相邻或相同位置认为回到起点
            print("✅ 已回到起点附近，形成闭合回路！")
            return true
        } else {
            print("❌ 距离起点太远(\(distance))，未形成闭合回路")
            return false
        }
    }
    
    /**
     * 检查从电池到灯泡是否有完整的电路路径
     * @param from 起点坐标（电池）
     * @param to 终点坐标（灯泡）
     * @param through 可通过的激活元件
     * @return 是否存在有效路径
     */
    private func hasCircuitPath(from start: AxialCoordinate, to end: AxialCoordinate, through activatedComponents: [AxialCoordinate: String]) -> Bool {
        print("🔍 检查路径: \(start) → \(end)")
        print("📍 可用激活元件: \(activatedComponents)")
        print("🛤️ 玩家路径: \(activatedPath)")
        
        // 如果起点和终点是同一个位置，不算有效路径
        if start == end {
            print("❌ 起点和终点相同，不算有效电路")
            return false
        }
        
        // 使用广度优先搜索(BFS)检查连通性
        var visited: Set<AxialCoordinate> = []
        var queue: [AxialCoordinate] = [start]
        visited.insert(start)
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            
            // 如果到达目标
            if current == end {
                print("✅ 找到从电池 \(start) 到灯泡 \(end) 的路径")
                return true
            }
            
            // 检查所有邻居
            let neighbors = hexMap.neighbors(of: current)
            for neighbor in neighbors {
                if visited.contains(neighbor) {
                    continue
                }
                
                var canPass = false
                
                // 可以通过激活的元件
                if activatedComponents.keys.contains(neighbor) {
                    if let componentType = activatedComponents[neighbor] {
                        if componentType == "switch" {
                            // 开关必须处于激活状态
                            canPass = componentNodes[neighbor]?.alpha == 1.0
                        } else {
                            // 其他元件（电池、灯泡、连接器）都可以通过
                            canPass = true
                        }
                    }
                }
                // 也可以通过玩家走过的路径（作为导线）
                else if activatedPath.contains(neighbor) {
                    canPass = true
                }
                
                if canPass {
                    visited.insert(neighbor)
                    queue.append(neighbor)
                    print("🚶 可以通过: \(neighbor)")
                }
            }
        }
        
        print("❌ 没有找到从电池 \(start) 到灯泡 \(end) 的完整路径")
        return false
    }
    
    /**
     * 检查开关是否处于闭合状态
     * @param coordinate 开关坐标
     * @return 是否闭合
     */
    private func isSwitchClosed(at coordinate: AxialCoordinate) -> Bool {
        guard let switchNode = componentNodes[coordinate] else { return false }
        // 简化实现：激活的开关就是闭合的
        return switchNode.alpha == 1.0
    }
}
