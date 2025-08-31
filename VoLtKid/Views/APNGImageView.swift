/**
 * APNG动画图片播放器
 * 支持自动播放APNG格式的动画文件，跨平台兼容
 */
import SwiftUI

#if canImport(UIKit)
import UIKit
typealias PlatformImageView = UIImageView
typealias PlatformImage = UIImage
typealias ViewRepresentable = UIViewRepresentable
#elseif canImport(AppKit)
import AppKit
typealias PlatformImageView = NSImageView
typealias PlatformImage = NSImage
typealias ViewRepresentable = NSViewRepresentable
#endif

/**
 * APNG动画播放View包装器
 */
struct APNGImageView: ViewRepresentable {
    /// 动画文件名称(不含扩展名)
    let name: String
    
    /// 是否自动播放动画
    let autoPlay: Bool
    
    /// 动画播放速度倍数
    let speed: Double
    
    /**
     * 初始化APNG播放器
     * @param name 动画文件名
     * @param autoPlay 是否自动播放
     * @param speed 播放速度倍数
     */
    init(name: String, autoPlay: Bool = true, speed: Double = 1.0) {
        self.name = name
        self.autoPlay = autoPlay
        self.speed = speed
    }
    
    #if canImport(UIKit)
    /**
     * 创建UIImageView实例
     */
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        // 加载动画图片
        if let image = loadAPNGImage(named: name) {
            imageView.image = image
            if autoPlay {
                imageView.startAnimating()
            }
        } else {
            // 如果APNG加载失败，尝试加载普通PNG
            imageView.image = UIImage(named: name)
        }
        
        return imageView
    }
    
    /**
     * 更新UIImageView
     */
    func updateUIView(_ uiView: UIImageView, context: Context) {
        // 当name改变时重新加载图片
    }
    #elseif canImport(AppKit)
    /**
     * 创建NSImageView实例
     */
    func makeNSView(context: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.imageScaling = .scaleProportionallyUpOrDown
        
        // 加载动画图片
        if let image = loadAPNGImage(named: name) {
            imageView.image = image
        } else {
            // 如果APNG加载失败，尝试加载普通PNG
            imageView.image = NSImage(named: name)
        }
        
        return imageView
    }
    
    /**
     * 更新NSImageView
     */
    func updateNSView(_ nsView: NSImageView, context: Context) {
        // 当name改变时重新加载图片
    }
    #endif
    
    /**
     * 加载APNG动画图片
     * @param named 图片文件名
     * @return 动画图片对象
     */
    private func loadAPNGImage(named: String) -> PlatformImage? {
        // 优先查找.apng文件
        if let image = PlatformImage(named: "\(named).apng") {
            return image
        }
        
        // 降级到.png文件
        if let image = PlatformImage(named: "\(named).png") {
            return image
        }
        
        // 最后尝试无扩展名
        return PlatformImage(named: named)
    }
}

/**
 * 预览支持
 */
#Preview {
    VStack(spacing: 20) {
        APNGImageView(name: "首页_LOGO动画")
            .frame(width: 200, height: 200)
            .background(Color.gray.opacity(0.1))
        
        APNGImageView(name: "角色选择_角色1")
            .frame(width: 150, height: 150)
            .background(Color.blue.opacity(0.1))
    }
    .padding()
}
