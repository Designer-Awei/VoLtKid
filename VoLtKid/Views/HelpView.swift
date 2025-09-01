/**
 * 帮助页面
 * 介绍游戏玩法与电路基础知识
 */
import SwiftUI

/**
 * 帮助视图
 */
struct HelpView: View {
    /// 当前选中的标签页
    @State private var selectedTab = 0
    
    /// 标签页标题
    private let tabTitles = ["游戏玩法", "电路知识", "角色介绍"]
    
    /// 导航控制
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // 自定义导航栏
            customNavigationBar
            
            // 标签页选择器
            tabSelector
            
            // 内容区域
            TabView(selection: $selectedTab) {
                    // 游戏玩法
                    gameplayContent
                        .tag(0)
                    
                    // 电路知识
                    circuitKnowledgeContent
                        .tag(1)
                    
                    // 角色介绍
                    roleIntroductionContent
                        .tag(2)
                }
#if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
#endif
        }
    }
    
    /**
     * 标签页选择器
     */
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabTitles.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = index
                    }
                }) {
                    Text(tabTitles[index])
                        .font(.headline)
                        .fontWeight(selectedTab == index ? .bold : .medium)
                        .foregroundColor(selectedTab == index ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            selectedTab == index ? 
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    /**
     * 游戏玩法内容
     */
    private var gameplayContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                helpSection(
                    icon: "gamecontroller.fill",
                    title: "基本操作",
                    color: .blue,
                    content: [
                        "• 点击角色进入连线模式",
                        "• 移动角色到电路元件上激活它们",
                        "• 连接足够的元件形成完整电路",
                        "• 点击暂停菜单可以切换角色"
                    ]
                )
                
                helpSection(
                    icon: "target",
                    title: "游戏目标",
                    color: .green,
                    content: [
                        "• 连接电池、开关和灯泡",
                        "• 让灯泡成功点亮",
                        "• 用最少的步数完成挑战",
                        "• 获得1-3颗星的评价"
                    ]
                )
                
                helpSection(
                    icon: "star.fill",
                    title: "评分系统",
                    color: .orange,
                    content: [
                        "⭐ 1星：完成关卡",
                        "⭐⭐ 2星：在推荐步数内完成",
                        "⭐⭐⭐ 3星：用最优步数完成",
                        "收集更多星星解锁新关卡！"
                    ]
                )
                
                helpSection(
                    icon: "hexagon.fill",
                    title: "六边形网格",
                    color: .purple,
                    content: [
                        "• 游戏采用六边形网格系统",
                        "• 每个格子可以放置电路元件",
                        "• 角色可以在相邻格子间移动",
                        "• 规划好路径是获得高分的关键"
                    ]
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
        }
    }
    
    /**
     * 电路知识内容
     */
    private var circuitKnowledgeContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                helpSection(
                    icon: "bolt.circle.fill",
                    title: "电池 (Battery)",
                    color: .green,
                    content: [
                        "🔋 电路的电源提供者",
                        "• 为整个电路提供电能",
                        "• 通常标有正极(+)和负极(-)",
                        "• 电流从正极流向负极",
                        "• 没有电池，电路无法工作"
                    ]
                )
                
                helpSection(
                    icon: "lightbulb.circle.fill",
                    title: "灯泡 (Bulb)",
                    color: .yellow,
                    content: [
                        "💡 电路的负载设备",
                        "• 将电能转换为光能",
                        "• 需要完整的电路才能点亮",
                        "• 电流通过灯丝产生光和热",
                        "• 是我们的主要目标设备"
                    ]
                )
                
                helpSection(
                    icon: "switch.2",
                    title: "开关 (Switch)",
                    color: .orange,
                    content: [
                        "🔘 电路的控制器",
                        "• 控制电路的通断",
                        "• 开关闭合时电路导通",
                        "• 开关断开时电路断开",
                        "• 可以控制灯泡的亮灭"
                    ]
                )
                
                helpSection(
                    icon: "link.circle.fill",
                    title: "连接器 (Connector)",
                    color: .blue,
                    content: [
                        "🔗 电路的连接点",
                        "• 连接不同的电路元件",
                        "• 让电流在元件间流动",
                        "• 确保电路路径完整",
                        "• 就像电路中的桥梁"
                    ]
                )
                
                helpSection(
                    icon: "arrow.triangle.2.circlepath",
                    title: "电路原理",
                    color: .indigo,
                    content: [
                        "⚡ 基本电路定律",
                        "• 电流需要形成闭合回路",
                        "• 电流从高电位流向低电位",
                        "• 断开的电路不会有电流",
                        "• 串联电路中电流处处相等"
                    ]
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
        }
    }
    
    /**
     * 角色介绍内容
     */
    private var roleIntroductionContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                Text("选择你的电路英雄")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 20) {
                    roleCard(
                        index: 0,
                        name: "电路探险家",
                        description: "勇敢的先锋，擅长快速连接电路元件",
                        specialty: "快速移动"
                    )
                    
                    roleCard(
                        index: 1,
                        name: "电学工程师",
                        description: "智慧的学者，能发现最优的电路路径",
                        specialty: "路径优化"
                    )
                    
                    roleCard(
                        index: 2,
                        name: "电子小精灵",
                        description: "活泼的助手，拥有特殊的跳跃能力",
                        specialty: "跳跃移动"
                    )
                    
                    roleCard(
                        index: 3,
                        name: "治愈师",
                        description: "温柔的守护者，能修复损坏的电路",
                        specialty: "电路修复"
                    )
                    
                    roleCard(
                        index: 4,
                        name: "电路法师",
                        description: "神秘的魔法师，掌握高级电路魔法",
                        specialty: "魔法连接"
                    )
                }
                .padding(.horizontal, 20)
                
                helpSection(
                    icon: "person.2.fill",
                    title: "角色切换",
                    color: .purple,
                    content: [
                        "• 在主页可以选择你喜欢的角色",
                        "• 游戏中可通过暂停菜单切换角色",
                        "• 不同角色有不同的视觉效果",
                        "• 选择你的专属电路英雄！"
                    ]
                )
            }
            .padding(.vertical, 15)
        }
    }
    
    /**
     * 角色卡片
     */
    private func roleCard(index: Int, name: String, description: String, specialty: String) -> some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: getRoleColors(index: index),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: getRoleIcon(index: index))
                    .font(.system(size: 35, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text(name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                Text("特长: \(specialty)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(getRoleColors(index: index)[0])
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(getRoleColors(index: index)[0].opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    /**
     * 帮助区块
     */
    private func helpSection(icon: String, title: String, color: Color, content: [String]) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(content, id: \.self) { text in
                    Text(text)
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(color.opacity(0.1))
        )
    }
    
    /**
     * 获取角色图标
     */
    private func getRoleIcon(index: Int) -> String {
        switch index {
        case 0:
            return "bolt.circle.fill"
        case 1:
            return "lightbulb.circle.fill"
        case 2:
            return "star.circle.fill"
        case 3:
            return "heart.circle.fill"
        case 4:
            return "diamond.circle.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
    
    /**
     * 获取角色颜色
     */
    private func getRoleColors(index: Int) -> [Color] {
        switch index {
        case 0:
            return [.orange, .red]
        case 1:
            return [.blue, .purple]
        case 2:
            return [.green, .teal]
        case 3:
            return [.pink, .purple]
        case 4:
            return [.indigo, .blue]
        default:
            return [.gray, .black]
        }
    }
    
    /**
     * 自定义导航栏
     */
    private var customNavigationBar: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left")
                        .font(.title3)
                    Text("返回")
                        .font(.body)
                }
                .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text("帮助")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            // 占位，保持标题居中
            HStack(spacing: 8) {
                Image(systemName: "arrow.left")
                    .font(.title3)
                Text("返回")
                    .font(.body)
            }
            .opacity(0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(getBackgroundColor())
    }
    
    /**
     * 获取背景颜色
     */
    private func getBackgroundColor() -> Color {
#if os(iOS)
        return Color(UIColor.systemBackground)
#else
        return Color(NSColor.controlBackgroundColor)
#endif
    }
}

/**
 * 预览支持
 */
#Preview {
    HelpView()
}
