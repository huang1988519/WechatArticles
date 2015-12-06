//
//  LoginController.swift
//  WechatArticle
//
//  Created by hwh on 15/11/18.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit
import AVOSCloud
//import JLToast

class LoginController: UIViewController {

    @IBOutlet weak var emailTextFiled: UITextField!
    @IBOutlet weak var secretTextFiled: UITextField!
    @IBOutlet weak var checkCodeTextLabel: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registButton: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func tap(sender: AnyObject) {
        self.view.endEditing(true)
    }
    @IBAction func dismiss(sender: AnyObject?) {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func regist(sender: AnyObject) {
        if emailTextFiled.text?.isEmpty == true {
            JLToast.makeText("邮箱呢?它能帮助你找回密码").show()
            return
        }
        if ((secretTextFiled.text?.isEmpty) == true) {
            JLToast.makeText("没有密码岂不是很没有安全感？").show()
            return
        }
        let email = emailTextFiled.text
        let secret = secretTextFiled.text
        
        let user = AVUser()
        user.username = email
        user.password = secret
        user.email    = email
        
        var error :NSError?
        let isSuc =  user.signUp(&error)
        if isSuc == false {
            JLToast.makeText("注册失败了 \n \((error?.localizedDescription)!)").show()
        }else{
            JLToast.makeText("注册成功").show()
            sendAuthEmailMessage(email!)
            self.dismiss(nil)
        }

    }
    @IBAction func Login(sender: AnyObject) {
        if emailTextFiled.text?.isEmpty == true {
            JLToast.makeText("邮箱呢?它能帮助你找回密码").show()
            return
        }
        if ((secretTextFiled.text?.isEmpty) == true) {
            JLToast.makeText("没有密码岂不是很没有安全感？").show()
            return
        }
        let email = emailTextFiled.text
        let secret = secretTextFiled.text
        do {
            let user:AVUser! =  try AVUser.logInWithUsername(email, password: secret, error:())
            if user == nil {
                JLToast.makeText("登录失败了").show()
            }else{
                JLToast.makeText("登录成功").show()
                self.dismiss(nil)
            }
        }catch {
            if let err = error as? NSError {
                if err.code == 211 {
                    JLToast.makeText("没有找到当前用户").show()
                }else{
                    JLToast.makeText(err.localizedDescription).show()
                }
            }else{
                JLToast.makeText("注册失败").show()
            }
            return
        }
    }
    /**
     发送邮箱确认邮件，但不用等待用户验证完成
     */
    func sendAuthEmailMessage(email:String) {
        AVUser.requestEmailVerify(email) {[unowned self] (completed, error) -> Void in
            if completed == true {
                JLToast.makeText("验证邮件已发送").show()
                self.dismiss(nil)
            }else{
                log.error("验证邮件发送失败了！！")
            }
        }
    }
    @IBAction func resetPassword(sender: UIButton) {
        if emailTextFiled.text?.isEmpty == true {
            JLToast.makeText("不输入邮件怎么找回密码...").show()
            return
        }
        let email = emailTextFiled.text!
        AVUser.requestPasswordResetForEmailInBackground(email)
        JLToast.makeText("已发送重置密码邮件，请注意查收").show()
        self.dismiss(nil)
    }
}
