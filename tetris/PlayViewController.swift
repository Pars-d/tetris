//
//  PlayViewController.swift
//  EID: wl8779
//  Course: CS371L
//
//  Created by user174376 on 7/8/20.
//  Copyright © 2020 top. All rights reserved.
//

import UIKit
import CoreData

class PlayViewController: UIViewController {

    @IBOutlet weak var pField: playFieldView!
    @IBOutlet weak var controlView: UIView!
    
    @IBOutlet weak var rAnticw: UIImageView!
    @IBOutlet weak var rCw: UIImageView!
    @IBOutlet weak var arrowDown: UIImageView!
    @IBOutlet weak var arrowLeft: UIImageView!
    @IBOutlet weak var arrowRight: UIImageView!
    
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var linesLbl: UILabel!
    @IBOutlet weak var tickLbl: UILabel!
    
    @IBOutlet var pauseGestureRecog: UITapGestureRecognizer!
    
    public static var pausingEnabled = true
    public static var tapsToPause = 2
    public static var isMirrored = false
    
    var isPaused = false
    var pauseLbl = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pField.init_gridImages()
        pField.init_objRefs(scoreLbl: scoreLbl, linesLbl: linesLbl, hostVC: self)
        
        pauseLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 225, height: 38))
        pauseLbl.center = CGPoint(x: pField.frame.width / 2, y: pField.frame.height / 2)
        pauseLbl.text = "PAUSED"
        pauseLbl.font = UIFont(name: "CourierNewPS-BoldMT", size: 35)
        pauseLbl.textColor = UIColor(red: 168.0/255.0, green: 5.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        pauseLbl.textAlignment = .center
        pauseLbl.backgroundColor = UIColor.black
        pauseLbl.isUserInteractionEnabled = false
        pauseLbl.isHidden = true
        pField.addSubview(pauseLbl)
        
        tickLbl.text = String(format: "%.1f", Mino.tickRate)
        
        pauseGestureRecog.isEnabled = PlayViewController.pausingEnabled
        pauseGestureRecog.numberOfTapsRequired = PlayViewController.tapsToPause
        
        if PlayViewController.isMirrored {
            var tmp = arrowLeft.frame.origin
            arrowLeft.frame.origin = rAnticw.frame.origin
            rAnticw.frame.origin = tmp
            
            tmp = arrowRight.frame.origin
            arrowRight.frame.origin = rCw.frame.origin
            rCw.frame.origin = tmp
        }

        
        let mino = Mino(shape: Mino.Shape.random(), x: 5, y: 0)
        pField.addMinoToPlayField(mino)
        mino.startDescent(pField: pField)
    }
    
    @IBAction func mLeft(_ sender: UITapGestureRecognizer) {
        pField.activeMino!.moveLeft(pField: pField)
    }
    @IBAction func mRight(_ sender: UITapGestureRecognizer) {
        pField.activeMino!.moveRight(pField: pField)
    }
    @IBAction func mDown(_ sender: UITapGestureRecognizer) {
        pField.activeMino!.hardDrop(pField: pField)
    }
    @IBAction func rAnticw(_ sender: UITapGestureRecognizer) {
        pField.activeMino!.rotateAntiCwise(pField: pField)
    }
    @IBAction func Cw(_ sender: UITapGestureRecognizer) {
        pField.activeMino!.rotateCwise(pField: pField)
    }
    
    @IBAction func pauseToggle(_ sender: UITapGestureRecognizer) {
        if isPaused { unpause() }
        else { pause() }
        
        isPaused = !isPaused
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }
        switch key.keyCode {
        case .keyboardLeftArrow: pField.activeMino!.moveLeft(pField: pField)
        case .keyboardRightArrow: pField.activeMino!.moveRight(pField: pField)
        case .keyboardZ: pField.activeMino!.rotateAntiCwise(pField: pField)
        case .keyboardX: pField.activeMino!.rotateCwise(pField: pField)
        case .keyboardC: pField.activeMino!.hardDrop(pField: pField)
        case .keyboardDownArrow: pField.activeMino!.softDrop()
        default: super.pressesBegan(presses, with: event)
        }
    }
    
    func pause() {
        pField.activeMino?.timer.invalidate()
        controlView.subviews.forEach({ $0.isUserInteractionEnabled = false })
        pField.bringSubviewToFront(pauseLbl)
        pauseLbl.isHidden = false
    }
    
    func unpause() {
        pauseLbl.isHidden = true
        controlView.subviews.forEach({ $0.isUserInteractionEnabled = true })
        pField.activeMino?.startDescent(pField: pField)
    }
    
    func gameOver() {
        
        // Save score to Core Data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Score", in: context)
        let newScore = NSManagedObject(entity: entity!, insertInto: context)
        newScore.setValue(pField.score, forKey: "score")
        newScore.setValue(pField.linesCleared, forKey: "lines")
        newScore.setValue(Date(), forKey: "date")
        do {
            try context.save()
        } catch {
            print("Context save failed.")
        }
        
        // Create 'GAME OVER' label
        let goView = UILabel(frame: CGRect(x: 0, y: 0, width: 225, height: 38))
        goView.center = CGPoint(x: pField.frame.width / 2, y: pField.frame.height / 2)
        goView.text = "GAME OVER"
        goView.font = UIFont(name: "CourierNewPS-BoldMT", size: 35)
        goView.textColor = UIColor(red: 168.0/255.0, green: 5.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        goView.textAlignment = .center
        goView.backgroundColor = UIColor.black
        goView.isUserInteractionEnabled = false
        pField.addSubview(goView)
        
        // Create 'Return to Title' button
        controlView!.subviews.forEach({ $0.removeFromSuperview() })
        let retToTitle = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: controlView!.frame.size))
        retToTitle.setTitle("Return to Title", for: .normal)
        retToTitle.setTitleColor(UIColor.black, for: .normal)
        retToTitle.titleLabel?.textAlignment = .center
        retToTitle.titleLabel?.font = UIFont.systemFont(ofSize: 49)
        retToTitle.addTarget(self, action: #selector(self.toMain), for: .touchUpInside)
        controlView.addSubview(retToTitle)
    }
    
    @objc func toMain() {
        performSegue(withIdentifier: "toMain", sender: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class playFieldView: UIView {
    
    var activeMino: Mino? = nil
    var scoreLbl: UILabel?  // References to objects on super view
    var linesLbl: UILabel?
    var hostViewController: PlayViewController?
    var score = 0 {
        didSet {
            scoreLbl!.text = "\(score)"
        }
    }
    var linesCleared = 0 {
        didSet {
            linesLbl!.text = "\(linesCleared)"
        }
    }
    static let bS = 28.0 // blockSize
    // false = space vacant, true = space occupied
    var grid = Array(repeating: Array(repeating: false, count: 20), count: 10) // grid[x][y]
    var gridImages = Array(repeating: Array(repeating: UIImageView(), count: 20), count: 10) // maintain a reference to image views
    
    func init_gridImages() {
        for i in 0...9 {
            for j in 0...19 {
                let newImage = UIImageView(image: UIImage(named: "white"))
                newImage.frame.origin = CGPoint(x: playFieldView.bS * Double(i), y: playFieldView.bS * Double(j))
                self.addSubview(newImage)
                gridImages[i][j] = newImage
            }
        }
    }
    
    func init_objRefs(scoreLbl: UILabel, linesLbl: UILabel, hostVC: PlayViewController) {
        self.scoreLbl = scoreLbl
        self.linesLbl = linesLbl
        self.hostViewController = hostVC
    }
    
    func addMinoToPlayField( _ mino: Mino) {
        activeMino = mino
        for block in mino.blocks {
            self.addSubview(block.display)
        }
    }
    
    func clearLines(linesToCheck: Set<Int>) {
        // Filter lines to those to clear
        var linesToClear = linesToCheck
        for line in linesToClear {
            for i in 0...9 {
                if !grid[i][line] {
                    linesToClear.remove(line)
                    break
                }
            }
        }
        if linesToClear.isEmpty { return }
        
        // Add score based on lines cleared
        switch linesToClear.count {
        case 1: score += 40
        case 2: score += 100
        case 3: score += 300
        case 4: score += 1200
        default: break
        }
        linesCleared += linesToClear.count
        
        // Sort to remove lines in proper order
        let sortedLinesToClear = linesToClear.sorted(by: <)
        
        // Visually clear lines
        for line in sortedLinesToClear { // For each complete line
            for i in 0...9 {
                grid[i][line] = false
            }
            
            for j in stride(from: line - 1, to: 0, by: -1) { // For each line above and equal to this complete line
                for i in 0...9 { // For each column
                    grid[i][j + 1] = grid[i][j]
                }
            }
            
            for i in 0...9 {
                grid[i][0] = false
            }
        }
        
        redraw()
        
    }
    
    func redraw() {
        self.subviews.forEach({
            if $0 is UIImageView {
                $0.removeFromSuperview()
            }
        })
        for i in 0...9 {
            for j in 0...19 {
                let newImage = grid[i][j] ?
                    UIImageView(image: UIImage(named: "square")) :
                    UIImageView(image: UIImage(named: "white"))
                newImage.frame.origin = CGPoint(x: playFieldView.bS * Double(i), y: playFieldView.bS * Double(j))
                self.addSubview(newImage)
//                gridImages[i][j] = newImage
            }
        }
    }
    
    func gameOver() {
        hostViewController?.gameOver()
    }

}

class Mino {
    var shape: Shape
    var rotation: Int = 0 // Rotation state: 0, 1, 2, 3   I, S, Z only have 0, 1   Sq only has 0
    
    // Dimensions counted in terms of blocks
    // Top-left corner is (0,0)
    // Bottom-right corner is (9, 19)
    // Counted in terms of blocks
    var x: Int  // Position of origin/rotation axis in relation to play field
    var y: Int  // I.e. x = 0, y = 0 for T mino would mean center block is in top left corner
    
//    var display: UIView
    var blocks: [Block] = []
    var timer: Timer
    
    public static var tickRate = 0.8
    
    enum Shape: CaseIterable {
        case I, J, L, S, T, Z, Sq
        
        static func random<G: RandomNumberGenerator>(using generator: inout G) -> Shape {
            return Shape.allCases.randomElement(using: &generator)!
        }
        static func random() -> Shape {
            var g = SystemRandomNumberGenerator()
            return Shape.random(using: &g)
        }
    }
    
    struct Block {
        var display: UIImageView
        var coord: (Int, Int) // In relation to mino origin (x, y)
        init(display: UIImageView, coord: (Int, Int)) {
            self.display = display
            self.coord = coord
        }
        enum Direction {
            case left, right, down
        }
        enum Rotation {
            case anticwise, cwise
        }
    }
    
    // Coordinates for collision checking and rotation
    // Origin is what block the rotation axis lies on
    // Refer to https://vignette.wikia.nocookie.net/tetrisconcept/images/0/07/NESTetris-pieces.png/revision/latest?cb=20061118190922
    static let I_coordDict = [0: [(-2,0), (-1,0), (0,0), (1,0)],
                              1: [(0,-2), (0,-1), (0,0), (0,1)]
                             ]
    static let Sq_coordDict = [0: [(0,0), (1,0), (0,1), (1,1)]  // (0,0) is top left corner
                             ]
    static let J_coordDict = [0: [(-1,0), (0,0), (1,0), (1,1)],
                              1: [(0,-1), (0,0), (-1,1), (0,1)],
                              2: [(-1,-1), (-1,0), (0,0), (1,0)],
                              3: [(0,-1), (1,-1), (0,0), (0,1)]
                             ]
    static let L_coordDict = [0: [(-1,0), (0,0), (1,0), (-1,1)],
                              1: [(-1,-1), (0,-1), (0,0), (0,1)],
                              2: [(1,-1), (-1,0), (0,0), (1,0)],
                              3: [(0,-1), (0,0), (0,1), (1,1)]
                             ]
    static let S_coordDict = [0: [(0,0), (1,0), (-1,1), (0,1)],
                              1: [(0,-1), (0,0), (1,0), (1,1)]
                             ]
    static let T_coordDict = [0: [(-1,0), (0,0), (1,0), (0,1)],
                              1: [(0,-1), (-1,0), (0,0), (0,1)],
                              2: [(0,-1), (-1,0), (0,0), (1,0)],
                              3: [(0,-1), (0,0), (1,0), (0,1)]
                             ]
    static let Z_coordDict = [0: [(-1,0), (0,0), (0,1), (1,1)],
                              1: [(1,-1), (0,0), (1,0), (0,1)]
                             ]
    static let dictMap = [Shape.I: I_coordDict,
                          Shape.J: J_coordDict,
                          Shape.L: L_coordDict,
                          Shape.S: S_coordDict,
                          Shape.T: T_coordDict,
                          Shape.Z: Z_coordDict,
                          Shape.Sq: Sq_coordDict
                         ]
    
    init(shape: Shape, x: Int, y: Int) {
        self.shape = shape
        self.x = x
        self.y = y
        self.timer = Timer()
        
        // This code creates the tetrimino visuals
        let dict = Mino.dictMap[shape]! // coordDict used for positioning blocks
        let bS = playFieldView.bS

        for coord in dict[0]! {
            let block = Block(display: UIImageView(image: UIImage(named: "square")), coord: coord)
            block.display.frame.origin = CGPoint(x: bS * Double(x + coord.0), y: bS * Double(y + coord.1))
            blocks.append(block)
        }
        
    }
    
    
    func startDescent(pField: playFieldView) {
        self.timer = Timer(timeInterval: Mino.tickRate, repeats: true) { timer in self.moveDown(pField: pField) }
        RunLoop.current.add(timer, forMode: .common)
    }
    
    
    /*
     * Translation methods
     */
    func moveDown(pField: playFieldView) {
        // Check for collision
        if !canMove(dir: .down, pField: pField) {
            // Stop block and clear lines
            self.timer.invalidate()
            var linesCovered: Set<Int> = []
            for block in blocks {
                pField.grid[self.x + block.coord.0][self.y + block.coord.1] = true
                pField.gridImages[self.x + block.coord.0][self.y + block.coord.1] = block.display
                linesCovered.insert(self.y + block.coord.1)
            }
            pField.clearLines(linesToCheck: linesCovered)
            
            // Spawn new block
            let mino = Mino(shape: Mino.Shape.random(), x: 5, y: 0)
            pField.addMinoToPlayField(mino)
            for block in mino.blocks { // Check for game over
                if pField.grid[mino.x + block.coord.0][mino.y + block.coord.1] {
                    pField.gameOver()
                    return
                }
            }
            mino.startDescent(pField: pField)
            return
        }

        // Lower block
        self.y += 1
        for block in blocks {
            block.display.frame.origin.y += CGFloat(playFieldView.bS)
        }
    }

    func moveLeft(pField: playFieldView) {
        // Check for collision
        if !canMove(dir: .left, pField: pField) {
            return
        }

        // Lower block
        self.x -= 1
        for block in blocks {
            block.display.frame.origin.x -= CGFloat(playFieldView.bS)
        }
    }
    
    func moveRight(pField: playFieldView) {
        // Check for collision
        if !canMove(dir: .right, pField: pField) {
            return
        }

        // Lower block
        self.x += 1
        for block in blocks {
            block.display.frame.origin.x += CGFloat(playFieldView.bS)
        }
    }
    
    // Check if any block would move into occupied space
    func canMove(dir: Block.Direction, pField: playFieldView) -> Bool {
        for block in blocks {
            switch dir {
            case .left:
                if self.x + block.coord.0 - 1 < 0
                || pField.grid[self.x + block.coord.0 - 1][self.y + block.coord.1]{
                    return false
                }
            case .right:
                if self.x + block.coord.0 + 1 > 9
                || pField.grid[self.x + block.coord.0 + 1][self.y + block.coord.1] {
                    return false
                }
            case .down:
                if self.y + block.coord.1 + 1 > 19
                || pField.grid[self.x + block.coord.0][self.y + block.coord.1 + 1] {
                    return false
                }
            }
        }
        return true
    }
    
    func softDrop() {
        timer.fire()
    }
    
    func hardDrop(pField: playFieldView) {
        self.timer.invalidate()
        // Check for collision
        while canMove(dir: .down, pField: pField) {
            // Lower block
            self.y += 1
            for block in blocks {
                block.display.frame.origin.y += CGFloat(playFieldView.bS)
            }
        }
        
        // Stop block and clear lines
        var linesCovered: Set<Int> = []
        for block in blocks {
            pField.grid[self.x + block.coord.0][self.y + block.coord.1] = true
            pField.gridImages[self.x + block.coord.0][self.y + block.coord.1] = block.display
            linesCovered.insert(self.y + block.coord.1)
        }
        pField.clearLines(linesToCheck: linesCovered)
        
        // Spawn new block
        let mino = Mino(shape: Mino.Shape.random(), x: 5, y: 0)
        pField.addMinoToPlayField(mino)
        for block in mino.blocks { // Check for game over
            if pField.grid[mino.x + block.coord.0][mino.y + block.coord.1] {
                pField.gameOver()
                return
            }
        }
        mino.startDescent(pField: pField)
    }
    
    
    /*
     * Rotation methods
     */
    func rotateAntiCwise(pField: playFieldView) {
        // Check for collision
        let tmp = canRotate(rot: .anticwise, pField: pField)
        if !tmp.0 {
            return
        }
        
        // Rotate anticlockwise
        self.rotation = tmp.1
        var i = 0
        for coord in Mino.dictMap[self.shape]![self.rotation]! {
            blocks[i].coord = coord
            blocks[i].display.frame.origin = CGPoint(x: playFieldView.bS * Double(x + coord.0), y: playFieldView.bS * Double(y + coord.1))
            i += 1
        }
    }
    
    func rotateCwise(pField: playFieldView) {
        // Check for collision
        let tmp = canRotate(rot: .cwise, pField: pField)
        if !tmp.0 {
            return
        }
        
        // Rotate clockwise
        self.rotation = tmp.1
        var i = 0
        for coord in Mino.dictMap[self.shape]![self.rotation]! {
            blocks[i].coord = coord
            blocks[i].display.frame.origin = CGPoint(x: playFieldView.bS * Double(x + coord.0), y: playFieldView.bS * Double(y + coord.1))
            i += 1
        }
    }
    
    // Returns if mino can rotate and rotation number it should be on
    func canRotate(rot: Block.Rotation, pField: playFieldView) -> (Bool, Int) {
        // Get coordinates of position to rotate to
        var tmpR = self.rotation
        let dict = Mino.dictMap[self.shape]! // tmp value
        switch shape {
        case .I, .S, .Z:
            tmpR = tmpR == 0 ? 1 : 0
        case .J, .L, .T:
            switch rot {
            case .anticwise:
                if tmpR == 0 { tmpR = 3 }
                else { tmpR -= 1 }
            case .cwise:
                if tmpR == 3 { tmpR = 0 }
                else { tmpR += 1 }
            }
        case .Sq:
            return (true, 0)
        }
        
        // Check if rotation would cause collision
        let tmpCoord = dict[tmpR]!
        for coord in tmpCoord {
            let tmpX = self.x + coord.0
            let tmpY = self.y + coord.1
            if tmpX < 0 || tmpX > 9 || tmpY < 0 || tmpY > 19
            || pField.grid[tmpX][tmpY]{
                return (false, self.rotation)
            }
        }
        
        return (true, tmpR)
    }
    
    
}

