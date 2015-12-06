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
import AVOSCloud
//import JLToast
//import Spring

class favoriteController: UIViewController,UITableViewDelegate,UITableViewDataSource ,UIViewControllerTransitioningDelegate{
    @IBOutlet weak var tableView: UITableView!
    var resultList: [AnyObject]?
    lazy var presentAnimation:TransitionZoom = {
        return TransitionZoom()
    }()
    class func Nib() -> favoriteController {
        let sb = MainSB()
        return (sb.instantiateViewControllerWithIdentifier("favoriteController") as? favoriteController)!
    }
    deinit {
        log.debug("收藏界面消除")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = AVUser.currentUser()
        if let _user = user {
            let query = AVQuery(className: FavoriteClassNameKey)
            query.whereKey(UserIdKey, equalTo: _user.objectId)
            resultList = query.findObjects()
            tableView.reloadData()
            JLToast.makeText("刷新成功").show()
        }else{
            alertWithMsg("请先登录了")
        }
        
    }
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK: --
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let node = resultList![indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as? ArticleListCell
        let imageUrl  = NSURL(string: (node["contentImg"] as? String)!)
        let avatarUrl = NSURL(string: (node["userLogo"] as? String)!)
        cell?.contentLabel.text = node["title"] as? String
        cell?.coverImageView.setUrl(imageUrl!)
        cell?.avatar.setUrl(avatarUrl!)
        cell?.ttitleLabel.text = node["userName"] as? String
        cell?.dateLabel.text = node["date"] as? String
        
        cell?.contentLabel.textColor = UIColor(white: 0.5, alpha: 1)
        cell?.setNeedsUpdateConstraints()
        cell?.updateConstraintsIfNeeded()
        return cell!
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultList == nil || resultList!.isEmpty == true {
            return 0
        }
        return (resultList!.count)
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let node = resultList![indexPath.row] as? AVObject
        var dic = [String:AnyObject]()
        for key in (node?.allKeys())! {
            dic[key as! String] = node![key as! String]
        }
        if dic.isEmpty {
            JLToast.makeText("数据错误").show()
            return
        }
        let detailVC = ArticleController.Nib()
        detailVC.inputDic = dic
        detailVC.transitioningDelegate = self
        self.presentViewController(detailVC, animated: true, completion: nil)
    }
    //MARK: -- Animatin Transition
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimation.animationControllerForPresentedController(presented, presentingController: presenting, sourceController: source)
    }
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimation.animationControllerForDismissedController(dismissed)
    }

}
