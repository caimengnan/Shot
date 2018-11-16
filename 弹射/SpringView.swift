//
//  SpringView.swift
//  弹射
//
//  Created by targeter on 2018/11/14.
//  Copyright © 2018年 targeter. All rights reserved.
//

import UIKit

class SpringView: UIView {
    
    //手指触摸点
    var touchPoint = CGPoint(x: kSCREEN_WIDTH/2, y: height)
    //两个点的中点线
    let middlePoint = CGPoint(x: kSCREEN_WIDTH/2, y: height)
    //左边点
    let leftPoint = CGPoint(x: 100, y: height)
    //右边点
    let rightPoint = CGPoint(x: kSCREEN_WIDTH - 100, y: height)
    //线段延长线上的一个点
    var anotherPoint = CGPoint(x: kSCREEN_WIDTH/2, y: height)
    //标记手势触摸是否结束
    var isEnd:Bool = false
    //初始化动画持有者
    
    
    lazy var circleView:UIView = {
        let circleView = UIView(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
        circleView.backgroundColor = .red
        circleView.layer.cornerRadius = 25
        
//        circleView.isUserInteractionEnabled = true
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panAction))
//        circleView.addGestureRecognizer(panGesture)
        return circleView
    }()
    
    //是否动画
    var useAnimation = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    func setUpUI() {
        
        self.addSubview(circleView)
        
        
    }
    
    
    
    
    
    override func draw(_ rect: CGRect) {

//        drawLinesWithUIGraphics()
        
        
        self.drawLinesWithUIBezierPath()
        self.drawDivideLine()
        
        
    }
    
    
    //MARK:UIGraphics绘制
    func drawLinesWithUIGraphics() {
        
        //获取模板
        let context = UIGraphicsGetCurrentContext()
        //填充颜色
        context?.setStrokeColor(UIColor.red.cgColor)
        //设置直线宽度
        context?.setLineWidth(2)
        
        context?.move(to: leftPoint)
        
        context?.addLine(to: touchPoint)
        context?.move(to: touchPoint)
        
        context?.addLine(to: rightPoint)
        context?.move(to: rightPoint)
        context?.strokePath()
        
    }
    
    //MARK:UIBezierPath绘制
    func drawLinesWithUIBezierPath() {
        
        let color = UIColor.red
        color.set()
        
        //添加贝塞尔曲线
        let path = UIBezierPath.init()
        path.move(to: leftPoint)
        
        path.addLine(to: touchPoint)
        path.addLine(to: rightPoint)
        
        path.lineWidth = 2.0
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        
        path.stroke()
        
    }
    
    //MARK:绘制平分线
    func drawDivideLine() {

        //获取模板
        let context = UIGraphicsGetCurrentContext()
        //填充颜色
        context?.setStrokeColor(UIColor.red.cgColor)
        //设置直线宽度
        context?.setLineWidth(2)
        
        context?.move(to: touchPoint)
        context?.addLine(to: anotherPoint)
        context?.move(to: anotherPoint)
        context?.setLineDash(phase: 0, lengths: [5])
        
        context?.strokePath()
        
    }
    
    //MARK:画圆
    func drawCircle() {
        
        
        
        
    }
    
    
    //MARK:贝塞尔曲线动画
    func addAnimation(path:UIBezierPath) {
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path.cgPath
        animation.duration = 0.5
        animation.repeatCount = 1
        animation.isRemovedOnCompletion = true
        animation.fillMode = .forwards
        self.layer.add(animation, forKey: nil)
    }
    
    //MARK:计算两个点之间的距离
    func caculateTheLengthOfTwoPoint(pointOne:CGPoint,pointTwo:CGPoint) -> CGFloat {
        var distance:CGFloat = 0
        distance = sqrt(pow(pointOne.x - pointTwo.x, 2) + pow(pointOne.y - pointOne.y, 2))
        return distance
    }
    
    //MARK:计算两个点连成的线段，线段延长线上的另一个点使得第二个点是中点
    func findAnotherPointWith(pointOne:CGPoint,pointTwo:CGPoint) -> CGPoint {
        
        var pointOne_copy = pointOne
        var pointTwo_copy = pointTwo
        if pointOne_copy.y < pointTwo_copy.y {
            pointOne_copy = pointTwo
            pointTwo_copy = pointOne
        }
        
        var otherPoint = CGPoint.zero
        otherPoint.x = 2 * pointTwo_copy.x - pointOne_copy.x
        otherPoint.y = 2 * pointTwo_copy.y - pointOne_copy.y
        
        return otherPoint
    }
    
    
    //MARK:开始触摸
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isEnd = false
        let touch = touches.first
        if touch != nil {
            let touchPoints = touch?.location(in: self)
            circleView.center = touchPoints!
            if ((touchPoints?.x)! > leftPoint.x && (touchPoints?.x)! < rightPoint.x && (touchPoints?.y)! >= rightPoint.y) {
                isEnd = true
            }
        }
        
        
    }
    
    //MARK:触摸移动
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        
        if touch != nil {
            let touchPoints = touch?.location(in: self)
            circleView.center = touchPoints!
            if isEnd == true { return }
            if ((touchPoints?.x)! > leftPoint.x && (touchPoints?.x)! < rightPoint.x && (touchPoints?.y)! >= rightPoint.y) {
                touchPoint = touchPoints!
                self.setNeedsDisplay()
                anotherPoint = findAnotherPointWith(pointOne: touchPoint, pointTwo: middlePoint)
            }
        }
    }
    
    //MARK:触摸结束
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //设置触摸状态
        isEnd = true
        //middlePoint恢复初始值
        touchPoint = CGPoint(x: kSCREEN_WIDTH/2, y: height)
        //延长线点恢复初始值
        anotherPoint = touchPoint
        self.setNeedsDisplay()
        
        //给圆球施加一个推力
        let dynamic = UIDynamicAnimator(referenceView: self)
        let push = UIPushBehavior(items: [circleView], mode: UIPushBehavior.Mode.instantaneous)
        push.magnitude = 2
        push.angle = 2
        dynamic.addBehavior(push)
        
    }
    

    
    //MARK:圆形拖动事件
    @objc func panAction(gesture:UIPanGestureRecognizer) {
        
        let gesturePoint = gesture.location(in: self)
        print(gesturePoint)
        
    }
    
    
}
