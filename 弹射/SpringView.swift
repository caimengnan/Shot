//
//  SpringView.swift
//  弹射
//
//  Created by targeter on 2018/11/14.
//  Copyright © 2018年 targeter. All rights reserved.
//

import UIKit

class SpringView: UIView {
    
    var dynamic: UIDynamicAnimator? = nil
    //手指触摸点
    var touchPoint = CGPoint(x: kSCREEN_WIDTH/2, y: height)
    //两个点的中点线
    let middlePoint = CGPoint(x: kSCREEN_WIDTH/2, y: height)
    //左边支点
    let leftPoint = CGPoint(x: 100, y: height)
    //右边支点
    let rightPoint = CGPoint(x: kSCREEN_WIDTH - 100, y: height)
    //线段延长线上的一个点（默认与中间点重合，移动时改变）
    var anotherPoint = CGPoint(x: kSCREEN_WIDTH/2, y: height)
    //标记手势触摸是否结束
    var isEnd:Bool = false
    //弹射角度
    var shotVector = CGVector.init()
    
    //复位按钮
    lazy var resetBtn:UIButton = {
       let resetBtn = UIButton(type: .custom)
        resetBtn.frame = CGRect(x: 200, y: 750, width: 150, height: 40)
        resetBtn.center.x = self.center.x
        resetBtn.backgroundColor = .yellow
        resetBtn.setTitle("复位", for: .normal)
        resetBtn.setTitleColor(UIColor.red, for: .normal)
        resetBtn.addTarget(self, action: #selector(resetAction), for: .touchUpInside)
        resetBtn.layer.cornerRadius = 5
        return resetBtn
    }()
    
    //画圆
    lazy var circleView:UIView = {
        let circleView = UIView(frame: CGRect(x: 50, y: 300, width: 50, height: 50))
        circleView.backgroundColor = .red
        circleView.layer.cornerRadius = 25
        return circleView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        self.addSubview(circleView)
        self.addSubview(resetBtn)
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
                shotVector = caculateTheVectorValueWithTwoPoint(pointOne: touchPoint, pointTwo: middlePoint)
            }
        }
    }
    
    //MARK:触摸结束
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //设置触摸状态
        isEnd = true
        
        let touch = touches.first
        if touch != nil {
            let touchPoints = touch?.location(in: self)
            circleView.center = touchPoints!
            if ((touchPoints?.x)! > leftPoint.x && (touchPoints?.x)! < rightPoint.x && (touchPoints?.y)! >= rightPoint.y) {
                
                //计算弹射角度 触摸点到两支点的距离比例
            shotVector = caculateTheVectorValueWithTwoPoint(pointOne: touchPoint, pointTwo: middlePoint)
                
                push()
            }
        }
        
        //middlePoint恢复初始值
        touchPoint = CGPoint(x: kSCREEN_WIDTH/2, y: height)
        //延长线点恢复初始值
        anotherPoint = touchPoint
        self.setNeedsDisplay()
       
    }
    
    //MARK:施加推力
    func push() {
        //给圆球施加一个推力
        dynamic = UIDynamicAnimator(referenceView: self)
        let push = UIPushBehavior(items: [circleView], mode: UIPushBehavior.Mode.instantaneous)
        push.magnitude = 100
//        push.angle = 1.5
        push.pushDirection = shotVector
        dynamic!.addBehavior(push)
    }
    
    //MARK:圆形拖动事件
    @objc func panAction(gesture:UIPanGestureRecognizer) {
        
        let gesturePoint = gesture.location(in: self)
        print(gesturePoint)
        
    }
    
    @objc func pushAction() {
        push()
    }
    
    
    //MARK:复位事件
    @objc func resetAction() {
        dynamic?.removeAllBehaviors()
        circleView.frame = CGRect(x: 50, y: 300, width: 50, height: 50)
    }
    
}

extension SpringView {
    
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
    
    
    //MARK:求两点连成直线的斜率（角度）
    func caculateTheVectorValueWithTwoPoint(pointOne:CGPoint,pointTwo:CGPoint) -> CGVector {
        
        var pointOne_copy = pointOne
        var pointTwo_copy = pointTwo
        if pointOne_copy.y < pointTwo_copy.y {
            pointOne_copy = pointTwo
            pointTwo_copy = pointOne
        }
        
        let xValue =  pointTwo_copy.x - pointOne_copy.x
        let yValue =  pointTwo_copy.y - pointOne_copy.y
        
        //取绝对值
        let xRealValue = fabsf(Float(xValue))
        let yRealValue = fabsf(Float(yValue))
        
        //取x、y对应的符号
        let xSymbol = xValue/CGFloat(xRealValue)
        let ySymbol = yValue/CGFloat(yRealValue)
        
        //取绝对值的商
        let x = xRealValue/yRealValue
        
        //得到化简后带符号的值
        let xFinal = xSymbol * CGFloat(x)
        let yFinal = ySymbol * 1
        
        
        return CGVector(dx: xFinal * 5, dy: yFinal * 5)
    }
    
}


