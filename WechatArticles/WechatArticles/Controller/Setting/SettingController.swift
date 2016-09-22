//                            _ooOoo_
//                           o8888888o
//                           88" . "88
//                           (| -_- |)
//                            O\ = /O
//                        ____/`---'\____
//                      .   ' \\| |// `.
//                       / \\||| : |||// \
//                     / _||||| -:- |||||- \
//                       | | \\\ - /// | |
//                     | \_| ''\---/'' | |
//                      \ .-\__ `-` ___/-. /
//                   ___`. .' /--.--\ `. . __
//                ."" '< `.___\_<|>_/___.' >'"".
//               | | : `- \`.;`\ _ /`;.`/ - ` : | |
//                 \ \ `-. \_ __\ /__ _/ .-` / /
//         ======`-.____`-.___\_____/___.-`____.-'======
//                            `=---='
//
//         .............................................
//                  佛祖保佑             永无BUG
//          佛曰:
//                  写字楼里写字间，写字间里程序员；
//                  程序人员写程序，又拿程序换酒钱。
//                  酒醒只在网上坐，酒醉还来网下眠；
//                  酒醉酒醒日复日，网上网下年复年。
//                  但愿老死电脑间，不愿鞠躬老板前；
//                  奔驰宝马贵者趣，公交自行程序员。
//                  别人笑我忒疯癫，我笑自己命太贱；
//                  不见满街漂亮妹，哪个归得程序员？


import UIKit
//import AVOSCloud
import CoreLocation
//import JLToast
//import Kingfisher
//import Spring

class SettingController: UITableViewController, CLLocationManagerDelegate,UIViewControllerTransitioningDelegate {

    @IBOutlet weak var userCell: UITableViewCell!
    @IBOutlet weak var cacheCell: UITableViewCell!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var pmLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    
    let locationManager :CLLocationManager = CLLocationManager()
    let ak = "3cSn0P7TOrl9veCRBDXwq7UF" //百度地图 ak
    let session = NSURLSession.sharedSession() //请求天气
    var cacheSize : CGFloat = 0{
        didSet {
            let m   = cacheSize/1024.0/1024.0
            let string = String(format: "%0.3f M", m)
            self.cacheCell.detailTextLabel?.text = string
            print("列表缓存 \((cacheSize/1024.0/1024.0)) M")
        }
    }
    var timer :NSTimer!
    var isLogin = false
    lazy var presentAnimation: PresentTransition = {
        return PresentTransition()
    }()
    let cacheManager = try! Cache<NSMutableDictionary>(name: "ListCache")

    
    class func Nib() -> SettingController {
        let sb = MainSB()
        return (sb.instantiateViewControllerWithIdentifier("SettingController") as? SettingController)!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.distanceFilter  = kCLLocationAccuracyKilometer
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        //ios 8 request
        locationManager.requestWhenInUseAuthorization()

        refreshWeather()
        
        //如果debug环境设置为 60s 刷新一次
        let time = 60.00*60.00
        #if DEDUG
            time = 60.00
        #endif
        //定时器
        timer = NSTimer(timeInterval: time, target: self, selector: Selector("refreshWeather"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        
        //计算图片缓存
        ImageCache.defaultCache.calculateDiskCacheSizeWithCompletionHandler { [unowned self](size) -> () in
            log.debug("图片缓存 %d M", args: size/1024/1024)
            self.cacheCell.detailTextLabel?.text = "\(size/1024/1024) M"
            self.cacheSize = self.cacheSize + CGFloat(size)
        }
        cacheManager.calculateDiskCacheSizeWithCompletionHandler {[unowned self] (size) -> () in
            self.cacheSize = self.cacheSize + CGFloat(size)
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        /*
        refreshUserInfo()
*/
    }
    /*
    /**
     退出登录
     
     - parameter sender: 按钮
     */
    @IBAction func logout(sender: AnyObject) {
        
        let alert = UIAlertController(title: "提示", message: "确定退出当前用户么", preferredStyle: .Alert)
        let sure = UIAlertAction(title: "登出", style: .Destructive) {[unowned self] (alert) -> Void in
            AVUser.logOut()
            self.isLogin = false
            self.userCell.textLabel?.text = "你好，最美陌生人（点击登录）"
        }
        let cancel = UIAlertAction(title: "取消", style: .Cancel) { (alert) -> Void in
            
        }
        alert.addAction(cancel)
        alert.addAction(sure)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func refreshUserInfo() {
        let currentUser = AVUser.currentUser()
        if let user = currentUser {
        isLogin = true
        
        userCell.textLabel?.text = "用户 \(user.username) 您好"
        }else{
        isLogin = false
        }
    }
*/
    /**
     刷新 坐标
     */
    func refreshWeather() {
        log.debug("重新定位")
        locationManager.delegate = self;
        locationManager.startUpdatingLocation()
    }
    /**
     请求天气信息
     
     - parameter location: 需要请求天气的坐标
     */
    func requestWeather(location:CLLocation) {
        let coordinate = location.coordinate
        
        let locationString = "location=\(coordinate.longitude),\(coordinate.latitude)"
        let urlString = "http://api.map.baidu.com/telematics/v3/weather?\(locationString)&output=json&ak=\(ak)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
//        request.addValue("", forHTTPHeaderField: "")
        let task = session.dataTaskWithRequest(request) { [unowned self](data, response, error) -> Void in
            if let res = response as? NSHTTPURLResponse {
                if res.statusCode != 200 {
                    log.error("请求天气error")
                    return
                }
            }
            if data == nil{
                log.error("返回的天气信息为空")
                return
            }
            do {
                let object = try NSJSONSerialization.JSONObjectWithData(data!, options: [.AllowFragments]) as? [String:AnyObject]
                if object == nil {
                    log.error("json 解析出错")
                }
                
                if let returnError = object!["error"] as? Int {
                    if returnError != 0 {
                        log.error("百度地图返回错误码\(object)")
                        return
                    }
                }
                guard let  dic = object!["results"] as? [[String:AnyObject]] else {
                    log.error("百度地图返回格式错误 \( object!["results"])")
                    return
                }
                if dic.count > 0  {
                    self.parserWeather(dic[0])
                }
                
            }catch {
                log.error("json 解析异常")
            }
            
        }
        task.resume()
    }
    func parserWeather(dic :[String:AnyObject]) {
        log.debug("天气信息为:\(dic)")
        let currentCity = dic["currentCity"] as? String!
        let pm25 = dic["pm25"] as? String!
        let weatherList = dic["weather_data"] as? [[String:AnyObject]]
        
        var weather :[String:AnyObject]?
        if weatherList?.count > 0 {
            weather = weatherList?.first
        }
        
        cityLabel.text = currentCity
        pmLabel.text   = "\(pm25!) -- PM2.5"
        if let tianqi = weather!["weather"] as? String! {
            weatherLabel.text = tianqi
        }
    }
    //MARK: --
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.isEmpty {
            log.error("没有定位信息！")
            return
        }
        let location = locations.first
        requestWeather(location!)
        locationManager.delegate = nil;
        locationManager.stopUpdatingLocation()
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        if error.code == CLError.Denied.rawValue {
            JLToast.makeText("定位被拒绝").show()
        }else{
            JLToast.makeText("定位失败").show()
        }
        locationManager.stopUpdatingLocation()

    }
    //MARK: --
    func clearImageCache() {
        let alert  = UIAlertController(title: "提示", message: "是否要删除图片缓存\n（温馨提示：如果清楚图片缓存，图片资源会重新从网上下载，消耗流量)" , preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "取消", style: .Cancel) { (action) -> Void in
            
        }
        let delete = UIAlertAction(title: "删除", style: .Destructive) {[unowned self] (action) -> Void in
            let strongself = self
            ImageCache.defaultCache.clearDiskCacheWithCompletionHandler({ () -> () in
                JLToast.makeText("缓存清理完成").show()
                strongself.cacheCell.detailTextLabel?.text = "0 M"
            })
            self.cacheManager.removeAllObjects()
        }
        alert.addAction(cancel)
        alert.addAction(delete)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    //MARK: --
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            clearImageCache()
        }
        /*
        if indexPath.row == 0 {
            if GetUserInfo() != nil && (isLogin == true) {
                
            }else{
                let nav = MainSB().instantiateViewControllerWithIdentifier("LoginControllerNav")
                App().window?.rootViewController?.presentViewController(nav, animated: true, completion: nil)
            }
        }
        if indexPath.row == 1 {
            if GetUserInfo() == nil {
                JLToast.makeText("你好,最美陌生人").show()
                return
            }
        
            let favoriteVC = favoriteController.Nib()
            favoriteVC.transitioningDelegate = self
            self.presentViewController(favoriteVC, animated: true, completion: nil)

        }
        if indexPath.row == 2 {
            clearImageCache()
        }
        if indexPath.row == 3 {
            let aboutVC = AboutController.Nib()
            aboutVC.transitioningDelegate = self
            self.presentViewController(aboutVC, animated: true, completion: nil)
        }
*/
        
    }
    //MARK: -- Animatin Transition
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimation.animationControllerForPresentedController(presented, presentingController: presenting, sourceController: source)
    }
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimation.animationControllerForDismissedController(dismissed)
    }
}
