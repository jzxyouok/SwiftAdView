//
//  RootViewController.swift
//  SwiftAdView
//
//  Created by mac on 2019/6/25.
//  Copyright © 2019年 mac. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    private lazy var showAdBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("showAgain", for: .normal)
        btn.backgroundColor = UIColor.gray
        btn.setTitleColor(UIColor.red, for: .normal)
        btn.addTarget(self, action: #selector(showAd), for: .touchUpInside)
        btn.frame = CGRect(x: 120, y: 250, width: 100, height: 40)
        return btn
    }()

    var isAdShow: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.title = "首页"
        view.addSubview(showAdBtn)
        
        loadADView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if !isAdShow {
//            loadADView()
//        }
    }
    
    @objc func showAd() {
        loadADView()
    }
    
    func loadADView() {
        if let currentAd = SwiftAdFileConfig.readCurrentAdModel() { // 1. 检测 本地 有没有 广告
            showAdView(currentAd)
        } else {
            showDefaultAd()  // 2. 本地没找到对应的广告文件，展示默认广告
        }
        // 3. 检测服务器是否 换了新广告
        loadAdAPI()
    }
    
    /// 展示默认 广告， 或者不展示广告
    func showDefaultAd() {
        /// image
        //let fileImage = Bundle.main.path(forResource: "guide02", ofType: "png") ?? ""
        /// gif
        let fileGif = Bundle.main.path(forResource: "foldingcell", ofType: "gif") ?? ""
        /// 视频
        // let fileVideo = Bundle.main.path(forResource: "1", ofType: "mp4") ?? ""
        
        let admodel = AdFileModel(adUrl: fileGif, adType: .gif, adHerfUrl: "https://github.com/shiliujiejie/RootTabBarController", adId: 1)
        
        showAdView(admodel)
    }
    
    func showAdView(_ adModel: AdFileModel) {
        let advc = SwiftAdView(config: configModel(), adModel: adModel)
        self.present(advc, animated: false, completion: nil)
        isAdShow = true
        advc.skipBtnClickHandler = {
            
        }
        advc.adClickHandler = { (adModel) in
            let webvc = WebKitController(url: URL(string: adModel.adHerfUrl ?? "")!)
            self.navigationController?.pushViewController(webvc, animated: true)
        }
    }
    
    /// 广告页面属性 - 配置
    func configModel() -> SwiftAdFileConfig {
        let config = SwiftAdFileConfig()
        config.duration = 10
        config.autoDissMiss = false
        config.openInSafari = false
        config.videoGravity = .resizeAspectFill
        return config
    }
    
}



// MARK: - 模拟 请求广告数据， 下载
extension RootViewController {
    
    /// 这里模拟网络请求到 广告数据 后的操作
    func loadAdAPI() {
        
        // 模拟网络请求1.5秒
        self.sleep(1.5) {
            /// 请求结果 构造 model (根据了 链接对应的数据 的文件格式。确定 adType : "image"   "gif"  "video")
            // https://github.com/shiliujiejie/adResource/raw/master/1.mp4
            // https://github.com/shiliujiejie/adResource/raw/master/2.mp4
            // https://github.com/shiliujiejie/adResource/raw/master/3.mp4
            // https://github.com/shiliujiejie/adResource/raw/master/folding-cell.gif
            // https://github.com/shiliujiejie/adResource/raw/master/maskp.gif
            // https://github.com/shiliujiejie/adResource/raw/master/timg.jpeg
            // http://cdn-hw.570920.com/video_ad/ao/7c/12ao7c3ee37f66d36b7f413a58d6483054aae59128.m3u8
            
            let admodel = AdFileModel.init(adUrl: "https://github.com/shiliujiejie/adResource/raw/master/bannerdemo.gif", adType: .gif, adHerfUrl: "https://github.com/shiliujiejie/RootTabBarController", adId: 0)
            
            /// 下载广告, 下次启动展示
            SwiftAdFileConfig.downLoadAdData(admodel)
        }
    }
    
    /// 线程延时
    private func sleep(_ time: Double,mainCall:@escaping ()->()) {
        let time = DispatchTime.now() + .milliseconds(Int(time * 1000))
        DispatchQueue.main.asyncAfter(deadline: time) {
            mainCall()
        }
    }
}
