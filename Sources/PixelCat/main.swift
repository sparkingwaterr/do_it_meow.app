import Cocoa

// MARK: - Sprite

let ink = NSColor(srgbRed: 0.11, green: 0.10, blue: 0.13, alpha: 1)
let colors: [Character: NSColor] = [
    "K": ink,
    "B": NSColor(srgbRed: 0.29, green: 0.28, blue: 0.33, alpha: 1),
    "W": .white,
    "P": NSColor(srgbRed: 0.96, green: 0.58, blue: 0.66, alpha: 1),
    "p": NSColor(srgbRed: 1.00, green: 0.82, blue: 0.85, alpha: 1),
    "F": NSColor(srgbRed: 0.66, green: 0.44, blue: 0.26, alpha: 1),
    "D": NSColor(srgbRed: 0.52, green: 0.74, blue: 0.96, alpha: 1),
    "S": NSColor(srgbRed: 0.74, green: 0.74, blue: 0.80, alpha: 1),
    "R": NSColor(srgbRed: 0.93, green: 0.42, blue: 0.50, alpha: 1),
    "r": NSColor(srgbRed: 1.00, green: 0.70, blue: 0.74, alpha: 1),
    "N": NSColor(srgbRed: 0.36, green: 0.36, blue: 0.78, alpha: 1),
    "Y": NSColor(srgbRed: 1.00, green: 0.88, blue: 0.48, alpha: 1),
]

// 잘 때 쓰는 수면 모자. 끝이 오른쪽으로 늘어지고 방울이 달려 있다
let nightcap = [
    "....KKKK......",
    "...KNNNNKK....",
    "..KNNNNNNNKKK.",
    ".KNNNNNNNNKYYK",
    "KYYYYYYYYYKKK.",
]
let snotBlue = NSColor(srgbRed: 0.45, green: 0.76, blue: 1.0, alpha: 1)
let snotShine = NSColor(srgbRed: 0.86, green: 0.95, blue: 1.0, alpha: 1)

// E/e 는 눈 (E는 깜빡일 때 lid 색으로 덮임), c 는 기분 좋을 때만 보이는 볼터치,
// wag 는 꼬리 흔들 때 바뀌는 줄
struct Design {
    let name: String
    let rows: [String]
    let wag: [Int: String]
    let eye: NSColor
    let lid: Character
    // 뛰는 동작 (쭉 뻗기 → 앞발 착지 → 모으기 → 뒷발로 차기). 각 장은 [몸 맨 아랫줄을 대신할 줄, 그 아래 다리 줄들...]
    // 천천히 걸을 때는 다리 없이 몸만 들썩이고, legs 가 없는 고양이는 뛸 때도 그렇게 움직인다
    var legs: [[String]] = []
    var peek = 7  // peekRows 가 없을 때: 창 뒤로 가라앉는 칸 수 (눈까지만 보이게)
    // 창 뒤에서 양팔을 걸치고 내다보는 그림. 마지막 pawOverhang 줄은 창 모서리 아래로 걸쳐지는 앞발
    var peekRows: [String] = []
    // 코 위치 (칸, 줄). 잘 때 여기서 콧방울이 나온다
    var nose = (x: 5, y: 5)
    var peekNose = (x: 9, y: 5)
    // 수면 모자의 왼쪽 위 모서리 위치 (칸, 줄). 머리 위로 올라가므로 줄은 음수
    var cap = (x: 0, y: -3)
    var peekCap = (x: 3, y: -3)
}
let pawOverhang = 2

// 세 마리 모두 같은 식빵 체형이고 무늬만 다르다. 뛰는 다리는 같이 쓴다
// 짧고 뭉툭한 발. 벌렸다 모았다 하면서 종종거린다
let loafLegs = [
    ["..WWKKKKKKKKKKWWK.",
     ".KWWK........KWWK.",
     "..KK..........KK.."],
    ["..KWWKKKKKKKKWWKK.",
     "..KWWK......KWWK..",
     "...KK........KK..."],
    ["..KKKKWWKKKWWKKKK.",
     ".....KWWK.KWWK....",
     "......KK...KK....."],
    ["..KKKWWKKKKKWWKKK.",
     "....KWWK...KWWK...",
     ".....KK.....KK...."],
]

let designs = [
    Design(name: "Tuxedo", rows: [
        ".KK...KK..........",
        "KBPK.KPBK.........",
        "KBBBKBBBKKKKKKK...",
        "KBBBBBBBBBBBBBBKK.",
        "KBBEBWBEBBBBBBBBBK",
        "KBceWPWecBBBBBBBBK",
        "KBWWWWWWWBBBBBBBBK",
        ".KWWWWWWBBBBBBBBBK",
        ".KWWWWWBBBBBBBWWWK",
        "..KKKKKKKKKKKKKKK.",
    ], wag: [
        7: ".KWWWWWWBBBBBBBWWK",
        8: ".KWWWWWBBBBBBWWWWK",
    ], eye: NSColor(srgbRed: 1.0, green: 0.85, blue: 0.35, alpha: 1), lid: "B", legs: loafLegs, peekRows: [
        "....KK.......KK...",
        "...KBPK.....KPBK..",
        "...KBBBKKKKKBBBK..",
        "...KBBBBBWBBBBBK..",
        "...KBBEBBWBBEBBK..",
        "...KBceWWPWWecBK..",
        "..KKKKWWWWWWWKKKK.",
        "..KWWK.......KWWK.",
        "...KK.........KK..",
    ]),

    Design(name: "Cow", rows: [
        ".KK...KK..........",
        "KBPK.KPBK.........",
        "KBBBKBBBKKKKKKK...",
        "KWWWBBWWWWWBBBWKK.",
        "KWWEWWWEWWBBBBBWWK",
        "KWceWPWecWWBBBWWWK",
        "KWWWWWWWWWWWWWWWWK",
        ".KWWWBBBWWWWWWWBBK",
        ".KWWWWBBWWWWWWBBBK",
        "..KKKKKKKKKKKKKKK.",
    ], wag: [
        7: ".KWWWBBBWWWWWWBBBK",
        8: ".KWWWWBBWWWWWBBBBK",
    ], eye: ink, lid: "W", legs: loafLegs, peekRows: [
        "....KK.......KK...",
        "...KBPK.....KPBK..",
        "...KBBBKKKKKBBBK..",
        "...KWWWWBBBWWWWK..",
        "...KWWEWWBWWEWWK..",
        "...KWceWWPWWecWK..",
        "..KKKKWWWWWWWKKKK.",
        "..KWWK.......KWWK.",
        "...KK.........KK..",
    ]),

    Design(name: "Loaf", rows: [
        ".KK...KK..........",
        "KBBK.KWWK.........",
        "KBBBKWWWKKKKKKK...",
        "KBBWWWWWWBBBBWWKK.",
        "KWWEWWWEWBBBBBWWWK",
        "KWceWPWecWBBBWWWWK",
        "KWWWWWWWWWWWWWWWWK",
        ".KWWWWWWWWWWWWWBBK",
        ".KWWWWWWWWWWWWBBBK",
        "..KKKKKKKKKKKKKKK.",
    ], wag: [
        7: ".KWWWWWWWWWWWWBBBK",
        8: ".KWWWWWWWWWWWBBBBK",
    ], eye: ink, lid: "W", legs: loafLegs, peekRows: [
        "....KK.......KK...",
        "...KBBK.....KWWK..",
        "...KBBBKKKKKWWWK..",
        "...KBBWWWWWWWWWK..",
        "...KWWEWWWWWEWWK..",
        "...KWceWWPWWecWK..",
        "..KKKKWWWWWWWKKKK.",
        "..KWWK.......KWWK.",
        "...KK.........KK..",
    ]),
]

let sizes: [(name: String, px: CGFloat)] = [("Small", 3), ("Medium", 4), ("Large", 5)]

final class CatView: NSView {
    var design = designs[0] { didSet { needsDisplay = true } }
    var px: CGFloat = 3 { didSet { needsDisplay = true } }
    var blink = false { didSet { needsDisplay = true } }
    var wag = false { didSet { needsDisplay = true } }
    var jump = 0 { didSet { needsDisplay = true } }  // 바닥에서 떠 있는 높이 (픽셀 칸 수)
    var happy = false { didSet { needsDisplay = true } }

    static let headroom = 6  // 뛰어오를 자리로 비워두는 위쪽 칸 수
    var spriteSize: NSSize {
        NSSize(width: CGFloat(design.rows[0].count) * px,
               height: CGFloat(design.rows.count + Self.headroom) * px)
    }
    var bodyRect: NSRect {
        NSRect(x: 0, y: CGFloat(Self.headroom) * px, width: bounds.width, height: CGFloat(design.rows.count) * px)
    }

    var walkFrame = 0 { didSet { needsDisplay = true } }  // 0 = 안 걷는 중, 1/2 = 걷는 동작
    var running = false { didSet { needsDisplay = true } }  // true 면 다리를 내고 뜀
    var dip = 0 { didSet { needsDisplay = true } }  // 밥 먹을 때 몸을 숙이는 칸 수
    var asleep = false { didSet { needsDisplay = true } }
    var snot = 0 { didSet { needsDisplay = true } }  // 콧방울 크기 0~3

    // 발밑 선 아래로 가라앉은 칸 수. 가라앉은 부분은 그리지 않아서 창 뒤에 숨은 것처럼 보인다.
    // peekRows 가 있으면 몸이 다 가라앉은 뒤(sink > 줄 수) 머리가 다시 올라와 앞발을 걸친다
    private(set) var sink = 0 { didSet { needsDisplay = true } }
    var sinkTarget = 0 { didSet { if sinkTarget != sink { animateSink() } } }
    var sinkTimer: Timer?

    var peekHead: Int { design.peekRows.count - pawOverhang }
    var hideDepth: Int { design.peekRows.isEmpty ? design.peek : design.rows.count + peekHead }
    var inPeek: Bool { !design.peekRows.isEmpty && sink > design.rows.count }

    func standUp() {
        sinkTarget = 0
        sink = 0
    }

    func animateSink() {
        guard sinkTimer == nil else { return }
        let t = Timer(timeInterval: 0.04, repeats: true) { [weak self] t in
            guard let self, self.sink != self.sinkTarget else {
                t.invalidate()
                self?.sinkTimer = nil
                return
            }
            self.sink += self.sink < self.sinkTarget ? 1 : -1
        }
        RunLoop.main.add(t, forMode: .common)
        sinkTimer = t
    }
    var facingRight = false { didSet { needsDisplay = true } }  // 그림은 왼쪽을 보고 있고, true 면 좌우로 뒤집음
    var isBusy: Bool { (hovering && mouseOver) || pressed || timer != nil }

    // 고양이가 스스로 움직여서 마우스 밑을 벗어나면 mouseExited 가 안 오므로 실제 위치로 다시 확인한다
    var mouseOver: Bool {
        guard let window else { return false }
        return bodyRect.contains(convert(window.convertPoint(fromScreen: NSEvent.mouseLocation), from: nil))
    }

    private(set) var pressed = false
    var hovering = false
    var jumpFrames: [Int] = []
    var tick = 0
    var timer: Timer?

    // 제자리 점프는 하지 않는다. 넘겨받은 길이만큼 기뻐하는 표정만 유지
    func hop(_ frames: [Int]) {
        jumpFrames = Array(repeating: 0, count: frames.count)
        startAnimating()
    }

    func startAnimating() {
        happy = true
        guard timer == nil else { return }
        tick = 0
        let t = Timer(timeInterval: 0.04, repeats: true) { [weak self] _ in self?.step() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func step() {
        tick += 1
        if hovering && !mouseOver { hovering = false }
        if tick % 3 == 0 { wag.toggle() }
        if !jumpFrames.isEmpty {
            jump = jumpFrames.removeFirst()
        } else if hovering {
            jump = 0
        } else {
            timer?.invalidate()
            timer = nil
            jump = 0
            wag = false
            happy = false
        }
    }

    override func updateTrackingAreas() {
        trackingAreas.forEach(removeTrackingArea)
        addTrackingArea(NSTrackingArea(rect: bodyRect, options: [.mouseEnteredAndExited, .mouseMoved, .activeAlways],
                                       owner: self, userInfo: nil))
    }

    override func mouseEntered(with event: NSEvent) {
        if asleep { return }  // 자는 동안은 마우스를 올려도 모른다. 클릭해야 깬다
        hovering = true
        hop([1, 2, 3, 3, 2, 1, 0])
    }

    override func mouseExited(with event: NSEvent) {
        hovering = false
        petAmount = 0
    }

    // 버튼을 누르지 않고 몸 위에서 마우스를 문지르면 쓰다듬는 것으로 친다
    override func mouseMoved(with event: NSEvent) {
        guard !asleep, !pressed else { return }
        petAmount += hypot(event.deltaX, event.deltaY)
        if petAmount > 90 {
            petAmount = 0
            onPet?()
        }
    }
    var onClick: ((Int) -> Void)?  // 연속으로 누른 횟수
    var onPet: (() -> Void)?       // 마우스로 쓰다듬었을 때
    var petAmount: CGFloat = 0
    var onMove: (() -> Void)?
    var menuProvider: (() -> NSMenu)?

    var dragStartMouse = NSPoint.zero
    var dragStartOrigin = NSPoint.zero
    var dragged = false

    override var isFlipped: Bool { true }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        let cols = design.rows[0].count
        let last = design.rows.count - 1
        // 앞쪽 다리 뒤로, 반 박자 어긋난 건너편 다리를 회색으로 겹쳐서 입체감을 준다
        let legs: [String]? = {
            guard running, walkFrame > 0, !design.legs.isEmpty else { return nil }
            let n = design.legs.count
            let near = design.legs[walkFrame - 1], far = design.legs[(walkFrame - 1 + n / 2) % n]
            return zip(near, far).enumerated().map { i, pair in
                String(zip(pair.0, pair.1).map { a, b -> Character in
                    let shade: Character = b == "W" ? "S" : b
                    if i == 0 { return a == "W" || shade != "S" ? a : shade }  // 몸 아랫줄: 다리가 붙는 자리만 튼다
                    return a != "." ? a : shade
                })
            }
        }()
        let lift = jump + (legs.map { $0.count - 1 } ?? (walkFrame == 1 ? 1 : 0)) - sink - dip

        func paint(_ row: String, _ y: Int) {
            guard y <= last else { return }
            for (x, ch) in row.enumerated() {
                let color: NSColor?
                switch ch {
                case "E": color = (blink || happy || asleep) ? colors[design.lid] : design.eye
                case "c": color = happy ? colors["p"] : colors[design.lid]
                case "e": color = design.eye
                default: color = colors[ch]
                }
                guard let color else { continue }
                color.setFill()
                let col = facingRight ? cols - 1 - x : x
                NSRect(x: CGFloat(col) * px, y: CGFloat(y + Self.headroom) * px, width: px, height: px).fill()
            }
        }

        // 코에서 왼쪽 아래로 매달린 콧방울. rowOffset 은 그림의 0번 줄이 그려지는 줄
        func drawSnot(_ nose: (x: Int, y: Int), _ rowOffset: Int) {
            guard asleep, snot > 0 else { return }
            let n = [0, 1, 2, 4][min(snot, 3)]  // 한 변의 칸 수
            for dy in 0..<n {
                for dx in 0..<n {
                    if n == 4 && (dx == 0 || dx == 3) && (dy == 0 || dy == 3) { continue }  // 모서리를 깎아 둥글게
                    let x = nose.x - 1 - dx, y = nose.y + 1 + dy + rowOffset
                    guard y <= last, x >= 0 else { continue }
                    (n > 1 && dx == n - 2 && dy == (n == 4 ? 1 : 0) ? snotShine : snotBlue).setFill()
                    let col = facingRight ? cols - 1 - x : x
                    NSRect(x: CGFloat(col) * px, y: CGFloat(y + Self.headroom) * px, width: px, height: px).fill()
                }
            }
        }

        func drawCap(_ at: (x: Int, y: Int), _ rowOffset: Int) {
            guard asleep else { return }
            for (r, row) in nightcap.enumerated() {
                paint(String(repeating: ".", count: at.x) + row, at.y + r + rowOffset)
            }
        }

        if inPeek {
            // 화면 맨 아래 pawOverhang 줄이 창 모서리 아래. 머리는 모서리 뒤에서 올라오고 앞발은 다 올라온 뒤에 걸친다
            let edge = last - pawOverhang
            let risen = sink - design.rows.count
            for (j, row) in design.peekRows.enumerated() {
                if j < peekHead {
                    let y = edge - risen + 1 + j - jump
                    if y <= edge { paint(row, y) }
                } else if risen == peekHead {
                    paint(row, edge + 1 + j - peekHead)
                }
            }
            if risen == peekHead {
                drawCap(design.peekCap, edge - peekHead + 1)
                drawSnot(design.peekNose, edge - peekHead + 1)
            }
            return
        }

        for (y, base) in design.rows.enumerated() {
            if let legs, y == last {
                paint(legs[0], y - lift)
            } else {
                paint(wag ? (design.wag[y] ?? base) : base, y - lift)
            }
        }
        for (i, row) in (legs ?? []).dropFirst().enumerated() {
            paint(row, last + 1 + i - lift)
        }
        drawCap(design.cap, -lift)
        drawSnot(design.nose, -lift)
    }

    override func mouseDown(with event: NSEvent) {
        pressed = true
        dragStartMouse = NSEvent.mouseLocation
        dragStartOrigin = window?.frame.origin ?? .zero
        dragged = false
    }

    override func mouseDragged(with event: NSEvent) {
        let m = NSEvent.mouseLocation
        let dx = m.x - dragStartMouse.x, dy = m.y - dragStartMouse.y
        if !dragged && abs(dx) < 3 && abs(dy) < 3 { return }
        dragged = true
        window?.setFrameOrigin(NSPoint(x: dragStartOrigin.x + dx, y: dragStartOrigin.y + dy))
        onMove?()
    }

    override func mouseUp(with event: NSEvent) {
        pressed = false
        if !dragged {
            if !asleep { hop([1, 3, 4, 5, 6, 6, 5, 4, 3, 1, 0, 0, 1, 2, 3, 3, 2, 1, 0]) }
            onClick?(event.clickCount)
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        guard let menu = menuProvider?() else { return }
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }
}

// MARK: - Todos

struct Todo: Codable {
    var text: String
    var done: Bool
    var due: Date?        // 알림 시각
    var today: Bool?      // "오늘 할 일"로 골라 둔 것
    var notified: Bool?   // 알림을 이미 보냈는지

    var isToday: Bool { today ?? false }
}

final class Store {
    let key = "todos"
    var onChange: ((_ old: [Todo], _ new: [Todo]) -> Void)?
    var todos: [Todo] {
        didSet {
            save()
            onChange?(oldValue, todos)
        }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode([Todo].self, from: data) {
            // 예전 버전이 넣어 둔 한국어 예시는 영어로 바꿔 준다
            let samples = [
                "고양이 눌러서 할 일 보기": "Click the cat to see to-dos",
                "아래 칸에 새 할 일 적기": "Type a new to-do below",
                "끝낸 일은 눌러서 체크": "Click an item to check it off",
            ]
            todos = saved.map { Todo(text: samples[$0.text] ?? $0.text, done: $0.done) }
        } else {
            todos = [
                Todo(text: "Click the cat to see to-dos", done: true),
                Todo(text: "Type a new to-do below", done: false),
                Todo(text: "Click an item to check it off", done: false),
            ]
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(data, forKey: key)
            UserDefaults.standard.synchronize()  // 갑자기 꺼져도 남도록 바로 내려쓴다
        }
    }
}

// MARK: - Bubble

let ringPink = NSColor(srgbRed: 0.96, green: 0.50, blue: 0.62, alpha: 1)
let ringGreen = NSColor(srgbRed: 0.36, green: 0.78, blue: 0.52, alpha: 1)

// 완료율 고리. 회색 바탕 고리 위에, 맨 위에서 시계 방향으로 완료한 만큼만 색을 칠한다
func drawRing(center: NSPoint, radius: CGFloat, width: CGFloat, fraction: CGFloat, flipped: Bool,
              color: NSColor? = nil) {
    let track = NSBezierPath()
    track.appendArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 360)
    track.lineWidth = width
    NSColor.gray.withAlphaComponent(0.28).setStroke()
    track.stroke()
    guard fraction > 0 else { return }
    let arc = NSBezierPath()
    let start: CGFloat = flipped ? 270 : 90
    arc.appendArc(withCenter: center, radius: radius, startAngle: start,
                  endAngle: flipped ? start + 360 * fraction : start - 360 * fraction, clockwise: !flipped)
    arc.lineWidth = width
    arc.lineCapStyle = .round
    (color ?? (fraction >= 1 ? ringGreen : ringPink)).setStroke()
    arc.stroke()
}

// 가운데에 큰 글자와 작은 글자가 들어가는 진행률 고리
final class RingView: NSView {
    var fraction: CGFloat = 0 { didSet { needsDisplay = true } }
    var big = "" { didSet { needsDisplay = true } }
    var small = "" { didSet { needsDisplay = true } }
    var color: NSColor? { didSet { needsDisplay = true } }
    var bigSize: CGFloat = 26

    override func draw(_ dirtyRect: NSRect) {
        let center = NSPoint(x: bounds.midX, y: bounds.midY)
        let thickness = max(8, min(bounds.width, bounds.height) * 0.09)
        drawRing(center: center, radius: min(bounds.width, bounds.height) / 2 - thickness, width: thickness,
                 fraction: fraction, flipped: false, color: color)
        let bigAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: bigSize, weight: .bold),
            .foregroundColor: NSColor.labelColor,
        ]
        let smallAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11, weight: .medium), .foregroundColor: NSColor.secondaryLabelColor,
        ]
        let b = (big as NSString).size(withAttributes: bigAttrs), sm = (small as NSString).size(withAttributes: smallAttrs)
        (big as NSString).draw(at: NSPoint(x: center.x - b.width / 2, y: center.y - b.height / 2 + 6),
                               withAttributes: bigAttrs)
        (small as NSString).draw(at: NSPoint(x: center.x - sm.width / 2, y: center.y - b.height / 2 - 8),
                                 withAttributes: smallAttrs)
    }
}

final class FlippedView: NSView {
    override var isFlipped: Bool { true }
}

// 모서리가 한 칸씩 깎인 테두리 + 계단 모양 꼬리 (뒤집힌 좌표계 기준)
func drawPixelBubble(body: NSRect, tailX: CGFloat, tailOnTop: Bool) {
    let u = BubbleView.u
    ink.setFill()
    body.insetBy(dx: u, dy: 0).fill()
    body.insetBy(dx: 0, dy: u).fill()
    NSColor.white.setFill()
    body.insetBy(dx: u * 2, dy: u).fill()
    body.insetBy(dx: u, dy: u * 2).fill()

    for i in 0..<3 {
        let w = CGFloat(4 - i) * u
        let y = tailOnTop ? body.minY - CGFloat(i + 1) * u : body.maxY + CGFloat(i) * u
        ink.setFill()
        NSRect(x: tailX, y: y, width: w, height: u).fill()
        if w > u * 2 {
            NSColor.white.setFill()
            NSRect(x: tailX + u, y: y, width: w - u * 2, height: u).fill()
        }
    }
    NSColor.white.setFill()
    NSRect(x: tailX + u, y: tailOnTop ? body.minY : body.maxY - u, width: u * 2, height: u).fill()
}

// 고양이가 한마디 할 때 뜨는 작은 말풍선
final class QuipView: NSView {
    static let font = NSFont.systemFont(ofSize: 12, weight: .heavy)
    static let heart = [".PP.PP.", "PPPPPPP", "PPPPPPP", ".PPPPP.", "..PPP..", "...P..."]
    static let heartPx: CGFloat = 2
    var text = "" { didSet { needsDisplay = true } }
    var showsHeart = false { didSet { needsDisplay = true } }  // 글자 대신 분홍 하트

    override var isFlipped: Bool { true }

    var neededSize: NSSize {
        if showsHeart {
            return NSSize(width: CGFloat(Self.heart[0].count) * Self.heartPx + 18,
                          height: CGFloat(Self.heart.count) * Self.heartPx + 14 + BubbleView.tailH)
        }
        let w = ceil((text as NSString).size(withAttributes: [.font: Self.font]).width)
        return NSSize(width: w + 22, height: 26 + BubbleView.tailH)
    }

    override func draw(_ dirtyRect: NSRect) {
        let body = NSRect(x: 0, y: 0, width: bounds.width, height: bounds.height - BubbleView.tailH)
        drawPixelBubble(body: body, tailX: bounds.width / 2 - BubbleView.u * 2, tailOnTop: false)
        if showsHeart {
            colors["P"]?.setFill()
            for (y, row) in Self.heart.enumerated() {
                for (x, ch) in row.enumerated() where ch == "P" {
                    NSRect(x: 9 + CGFloat(x) * Self.heartPx, y: 7 + CGFloat(y) * Self.heartPx,
                           width: Self.heartPx, height: Self.heartPx).fill()
                }
            }
            return
        }
        (text as NSString).draw(at: NSPoint(x: 11, y: 5), withAttributes: [.font: Self.font, .foregroundColor: ink])
    }
}

final class RowView: NSView {
    let done: Bool
    let deleteButton: NSButton
    var onToggle: (() -> Void)?
    var onDelete: (() -> Void)?

    override var isFlipped: Bool { true }

    init(frame: NSRect, todo: Todo) {
        done = todo.done
        deleteButton = NSButton(title: "×", target: nil, action: nil)
        super.init(frame: frame)

        var attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13, weight: .medium),
            .foregroundColor: todo.done ? NSColor(white: 0.62, alpha: 1) : ink,
        ]
        if todo.done { attrs[.strikethroughStyle] = NSUnderlineStyle.single.rawValue }
        let label = NSTextField(labelWithAttributedString: NSAttributedString(string: todo.text, attributes: attrs))
        label.lineBreakMode = .byTruncatingTail
        label.frame = NSRect(x: 22, y: 2, width: frame.width - 22 - 20, height: 18)
        addSubview(label)

        deleteButton.isBordered = false
        deleteButton.font = NSFont.systemFont(ofSize: 14, weight: .bold)
        deleteButton.contentTintColor = NSColor(white: 0.7, alpha: 1)
        deleteButton.target = self
        deleteButton.action = #selector(deleteClicked)
        deleteButton.frame = NSRect(x: frame.width - 18, y: 1, width: 18, height: 20)
        addSubview(deleteButton)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func hitTest(_ point: NSPoint) -> NSView? {
        guard let hit = super.hitTest(point) else { return nil }
        return hit === deleteButton ? hit : self
    }

    override func draw(_ dirtyRect: NSRect) {
        let box = NSRect(x: 2, y: 5, width: 12, height: 12)
        ink.setFill()
        box.fill()
        NSColor.white.setFill()
        box.insetBy(dx: 2, dy: 2).fill()
        if done {
            ink.setFill()
            box.insetBy(dx: 4, dy: 4).fill()
        }
    }

    override func mouseDown(with event: NSEvent) { onToggle?() }
    @objc func deleteClicked() { onDelete?() }
}

final class BubbleView: NSView, NSTextViewDelegate {
    static let width: CGFloat = 236
    static let u: CGFloat = 3
    static let tailH: CGFloat = 9
    static let pad: CGFloat = 15
    static let rowH: CGFloat = 22
    static let tabH: CGFloat = 26
    static let noteH: CGFloat = 132

    let store: Store
    weak var notes: NotesPane?
    let field = NSTextField()
    var tailX: CGFloat = 40
    var tailOnTop = false
    var onChange: (() -> Void)?

    // 위쪽 탭으로 할 일과 메모를 오간다
    var showsNotes = UserDefaults.standard.bool(forKey: "bubbleNotes")
    var noteIndex = 0
    private var shownNote: UUID?
    private let todoTab = NSButton(title: "", target: nil, action: nil)
    private let memoTab = NSButton(title: "", target: nil, action: nil)
    private let prevNote = NSButton(title: "‹", target: nil, action: nil)
    private let nextNote = NSButton(title: "›", target: nil, action: nil)
    private let addNote = NSButton(title: "+", target: nil, action: nil)
    private let deleteNote = NSButton(title: "×", target: nil, action: nil)
    private var confirmDeleteUntil = Date.distantPast  // 이 시각 전에 × 를 한 번 더 누르면 지운다
    private let noteScroll = NSTextView.scrollableTextView()
    private var noteText: NSTextView { noteScroll.documentView as! NSTextView }
    private var dynamic: [NSView] = []  // 다시 그릴 때마다 새로 만드는 것들 (제목, 할 일 줄)

    override var isFlipped: Bool { true }

    init(store: Store) {
        self.store = store
        super.init(frame: .zero)
        field.isBordered = false
        field.drawsBackground = false
        field.focusRingType = .none
        field.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        field.textColor = ink
        field.placeholderString = "+ Add a to-do"
        field.cell?.sendsActionOnEndEditing = false
        field.target = self
        field.action = #selector(addTodo)
        addSubview(field)

        for (button, action) in [(todoTab, #selector(showTodos)), (memoTab, #selector(showMemos)),
                                 (prevNote, #selector(previousNote)), (nextNote, #selector(followingNote)),
                                 (addNote, #selector(newNote)),
                                 (deleteNote, #selector(removeNote))] {
            button.isBordered = false
            button.target = self
            button.action = action
            button.font = NSFont.systemFont(ofSize: 15, weight: .heavy)
            button.contentTintColor = ink
            addSubview(button)
        }

        noteScroll.drawsBackground = false
        noteScroll.borderType = .noBorder
        noteScroll.hasVerticalScroller = true
        noteScroll.autohidesScrollers = true
        noteText.drawsBackground = false
        noteText.isRichText = false
        noteText.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        noteText.textColor = ink
        noteText.insertionPointColor = ink
        noteText.textContainerInset = NSSize(width: 0, height: 2)
        noteText.delegate = self
        addSubview(noteScroll)
    }

    required init?(coder: NSCoder) { fatalError() }

    var bodyHeight: CGFloat {
        let content = showsNotes ? 22 + Self.noteH + 4
            : 22 + CGFloat(store.todos.count) * Self.rowH + 6 + 22
        return Self.pad + Self.tabH + content + Self.pad - 3
    }
    var neededSize: NSSize { NSSize(width: Self.width, height: bodyHeight + Self.tailH) }
    var bodyTop: CGFloat { tailOnTop ? Self.tailH : 0 }
    private var contentTop: CGFloat { bodyTop + Self.pad - 4 + Self.tabH }

    private func heading(_ text: String, y: CGFloat, width: CGFloat) {
        let title = NSTextField(labelWithString: text)
        title.font = NSFont.systemFont(ofSize: 12, weight: .heavy)
        title.textColor = ink
        title.lineBreakMode = .byTruncatingTail
        title.frame = NSRect(x: Self.pad, y: y, width: width, height: 18)
        addSubview(title)
        dynamic.append(title)
    }

    func rebuild() {
        dynamic.forEach { $0.removeFromSuperview() }
        dynamic = []
        setFrameSize(neededSize)
        let inner = Self.width - Self.pad * 2

        // 탭: 고른 쪽은 진하게, 아닌 쪽은 흐리게
        for (tab, name, active, x) in [(todoTab, "To-Do", !showsNotes, Self.pad), (memoTab, "Memo", showsNotes, Self.pad + 64)] {
            tab.attributedTitle = NSAttributedString(string: name, attributes: [
                .font: NSFont.systemFont(ofSize: 12, weight: .heavy),
                .foregroundColor: active ? ink : NSColor(white: 0.66, alpha: 1),
            ])
            tab.frame = NSRect(x: x, y: bodyTop + Self.pad - 5, width: 56, height: 20)
        }

        var y = contentTop
        field.isHidden = showsNotes
        for v in [prevNote, nextNote, addNote, deleteNote, noteScroll] as [NSView] { v.isHidden = !showsNotes }

        if showsNotes {
            let all = notes?.notes ?? []
            noteIndex = min(max(noteIndex, 0), max(all.count - 1, 0))
            let confirming = Date() < confirmDeleteUntil
            heading(all.isEmpty ? "No memos yet" : confirming ? "× again: delete" : "Memo \(noteIndex + 1) of \(all.count)",
                    y: y, width: inner - 92)
            deleteNote.frame = NSRect(x: Self.width - Self.pad - 88, y: y - 4, width: 20, height: 22)
            deleteNote.isEnabled = !all.isEmpty
            deleteNote.contentTintColor = confirming ? colors["R"] : NSColor(white: 0.6, alpha: 1)
            addNote.frame = NSRect(x: Self.width - Self.pad - 20, y: y - 3, width: 20, height: 22)
            nextNote.frame = NSRect(x: Self.width - Self.pad - 42, y: y - 4, width: 20, height: 22)
            prevNote.frame = NSRect(x: Self.width - Self.pad - 64, y: y - 4, width: 20, height: 22)
            prevNote.isEnabled = noteIndex > 0
            nextNote.isEnabled = noteIndex < all.count - 1
            y += 22
            noteScroll.frame = NSRect(x: Self.pad, y: y, width: inner, height: Self.noteH)
            let current = all.indices.contains(noteIndex) ? all[noteIndex] : nil
            noteText.isEditable = current != nil
            // 쓰고 있는 중에는 글자를 덮어쓰지 않는다. 다른 메모로 넘어갔을 때만 바꾼다
            if current?.id != shownNote || (window?.firstResponder !== noteText && noteText.string != (current?.text ?? "")) {
                noteText.string = current?.text ?? ""
                shownNote = current?.id
            }
        } else {
            let left = store.todos.filter { !$0.done }.count
            heading(left == 0 ? "All done! Meow" : "\(left) to-do\(left == 1 ? "" : "s") left, meow", y: y, width: inner - 20)
            y += 22
            for (i, todo) in store.todos.enumerated() {
                let row = RowView(frame: NSRect(x: Self.pad, y: y, width: inner, height: Self.rowH), todo: todo)
                row.onToggle = { [weak self] in
                    self?.store.todos[i].done.toggle()
                    self?.onChange?()
                }
                row.onDelete = { [weak self] in
                    self?.store.todos.remove(at: i)
                    self?.onChange?()
                }
                addSubview(row)
                dynamic.append(row)
                y += Self.rowH
            }
            y += 6
            field.frame = NSRect(x: Self.pad, y: y, width: inner, height: 20)
        }
        needsDisplay = true
    }

    @objc func addTodo() {
        let text = field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        field.stringValue = ""
        store.todos.append(Todo(text: text, done: false))
        onChange?()
    }

    func setMode(notes: Bool) {
        showsNotes = notes
        UserDefaults.standard.set(notes, forKey: "bubbleNotes")
        onChange?()
    }

    @objc func showTodos() { setMode(notes: false) }
    @objc func showMemos() { setMode(notes: true) }

    @objc func previousNote() {
        noteIndex -= 1
        onChange?()
    }

    @objc func followingNote() {
        noteIndex += 1
        onChange?()
    }

    @objc func newNote() {
        notes?.newNote()
        noteIndex = 0
        onChange?()
        window?.makeFirstResponder(noteText)
    }

    // 실수로 지우지 않게 두 번 눌러야 지워진다
    @objc func removeNote() {
        if Date() < confirmDeleteUntil {
            confirmDeleteUntil = .distantPast
            notes?.delete(at: noteIndex)
            shownNote = nil
            onChange?()
        } else {
            confirmDeleteUntil = Date() + 3
            onChange?()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) { [weak self] in self?.onChange?() }
        }
    }

    func textDidChange(_ notification: Notification) {
        notes?.update(noteIndex, text: noteText.string)
    }

    override func draw(_ dirtyRect: NSRect) {
        let body = NSRect(x: 0, y: bodyTop, width: bounds.width, height: bodyHeight)

        drawPixelBubble(body: body, tailX: tailX, tailOnTop: tailOnTop)

        // 고른 탭 밑의 굵은 줄과, 탭 줄 전체 밑의 점선
        let active = showsNotes ? memoTab : todoTab
        ink.setFill()
        NSRect(x: active.frame.minX + 6, y: active.frame.maxY + 1, width: active.frame.width - 12, height: 3).fill()
        NSColor(white: 0.8, alpha: 1).setFill()
        var x = Self.pad
        while x < bounds.width - Self.pad {
            NSRect(x: x, y: active.frame.maxY + 5, width: 3, height: 1.5).fill()
            if !showsNotes { NSRect(x: x, y: field.frame.minY - 4, width: 3, height: 1.5).fill() }  // 입력칸 위
            x += 6
        }

        // 제목 오른쪽의 작은 완료율 고리
        let total = store.todos.count
        if !showsNotes && total > 0 {
            drawRing(center: NSPoint(x: bounds.width - Self.pad - 8, y: contentTop + 9), radius: 6, width: 3,
                     fraction: CGFloat(store.todos.filter(\.done).count) / CGFloat(total), flipped: true)
        }
    }
}

final class KeyPanel: NSPanel {
    override var canBecomeKey: Bool { true }
}

// MARK: - Food and toys

// 손으로 집어서 옮길 수 있는 작은 물건 (밥그릇, 털실 공)
class ItemView: NSView {
    var px: CGFloat = 3 { didSet { needsDisplay = true } }
    var rows: [String] { [] }
    var neededSize: NSSize { NSSize(width: CGFloat(rows[0].count) * px, height: CGFloat(rows.count) * px) }

    var onGrab: (() -> Void)?
    var onDrop: ((NSPoint) -> Void)?  // 놓는 순간의 속도 (포인트/초)

    var grabOffset = NSPoint.zero
    var trail: [(p: NSPoint, t: TimeInterval)] = []

    override var isFlipped: Bool { true }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        for (y, row) in rows.enumerated() {
            for (x, ch) in row.enumerated() {
                guard let color = colors[ch] else { continue }
                color.setFill()
                NSRect(x: CGFloat(x) * px, y: CGFloat(y) * px, width: px, height: px).fill()
            }
        }
    }

    override func mouseDown(with event: NSEvent) {
        let m = NSEvent.mouseLocation, o = window?.frame.origin ?? .zero
        grabOffset = NSPoint(x: m.x - o.x, y: m.y - o.y)
        trail = [(m, event.timestamp)]
        onGrab?()
    }

    override func mouseDragged(with event: NSEvent) {
        let m = NSEvent.mouseLocation
        window?.setFrameOrigin(NSPoint(x: m.x - grabOffset.x, y: m.y - grabOffset.y))
        trail.append((m, event.timestamp))
        trail.removeAll { event.timestamp - $0.t > 0.12 }
    }

    override func mouseUp(with event: NSEvent) {
        var v = NSPoint.zero
        if let first = trail.first, let last = trail.last, last.t - first.t > 0.01, event.timestamp - last.t < 0.1 {
            v = NSPoint(x: (last.p.x - first.p.x) / (last.t - first.t), y: (last.p.y - first.p.y) / (last.t - first.t))
        }
        onDrop?(v)
    }
}

// 밥그릇. 먹을수록 단계가 올라가고 마지막 단계는 빈 그릇
let bowlStages = [
    ["...FFFF...", "..FFFFFF..", "KKKKKKKKKK", ".KDDDDDDK.", "..KKKKKK.."],
    ["..........", "..FFFFFF..", "KKKKKKKKKK", ".KDDDDDDK.", "..KKKKKK.."],
    ["..........", "..........", "KKKKKKKKKK", ".KDDDDDDK.", "..KKKKKK.."],
]

final class BowlView: ItemView {
    var stage = 0 { didSet { needsDisplay = true } }
    override var rows: [String] { bowlStages[min(stage, bowlStages.count - 1)] }
}

// 털실 공. 굴러갈 때 두 장을 번갈아 보여준다
let ballFrames = [
    ["..KKKK..", ".KRrRRK.", "KRRrRRrK", "KrRRrRRK", "KRrRRrRK", "KRRrRRrK", ".KRRrRK.", "..KKKK.."],
    ["..KKKK..", ".KRRrRK.", "KrRRrRRK", "KRrRRrRK", "KRRrRRrK", "KrRRrRRK", ".KRrRRK.", "..KKKK.."],
]

final class BallView: ItemView {
    var frameIndex = 0 { didSet { needsDisplay = true } }
    override var rows: [String] { ballFrames[frameIndex % ballFrames.count] }
}

// MARK: - Other apps' windows

// 다른 앱의 보통 창. frame 은 Cocoa 좌표 (왼쪽 아래가 원점)
struct Win {
    let id: CGWindowID
    let frame: NSRect
}

// 앞에 있는 창부터 순서대로. 창 위치만 읽고 내용이나 제목은 보지 않는다
func visibleWindows() -> [Win] {
    let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
    guard let list = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else { return [] }
    let primaryHeight = NSScreen.screens.first?.frame.height ?? 0
    let me = ProcessInfo.processInfo.processIdentifier
    return list.compactMap { info in
        guard (info[kCGWindowLayer as String] as? Int) == 0,
              (info[kCGWindowOwnerPID as String] as? Int32) != me,
              (info[kCGWindowAlpha as String] as? Double ?? 1) > 0,
              let id = info[kCGWindowNumber as String] as? CGWindowID,
              let dict = info[kCGWindowBounds as String] as? NSDictionary,
              let r = CGRect(dictionaryRepresentation: dict),
              r.width >= 160, r.height >= 80 else { return nil }
        return Win(id: id, frame: NSRect(x: r.minX, y: primaryHeight - r.maxY, width: r.width, height: r.height))
    }
}

// 맥북 화면 위쪽 가운데의 노치(카메라 자리)가 가리는 가로 범위.
// 바닥 높이 y 에 키 height 인 것이 메뉴 막대 높이까지 올라올 때만 값이 있다
func notchRange(atY y: CGFloat, height: CGFloat) -> ClosedRange<CGFloat>? {
    for screen in NSScreen.screens where screen.safeAreaInsets.top > 0 {
        guard let left = screen.auxiliaryTopLeftArea, let right = screen.auxiliaryTopRightArea,
              y < screen.frame.maxY, y + height > screen.frame.maxY - screen.safeAreaInsets.top else { continue }
        let width = screen.frame.width - left.width - right.width
        guard width > 0 else { continue }
        let margin: CGFloat = 8  // 노치 가장자리에 바짝 붙지 않게
        return (screen.frame.midX - width / 2 - margin)...(screen.frame.midX + width / 2 + margin)
    }
    return nil
}

// 고양이가 올라앉은 창
struct Perch {
    let id: CGWindowID
    var bounds: NSRect
    var offsetX: CGFloat  // 창 왼쪽 끝에서 고양이까지의 거리
}

let debugLog = ProcessInfo.processInfo.environment["PIXELCAT_DEBUG"] != nil
func log(_ message: String) {
    if debugLog { print(message); fflush(stdout) }
}

// MARK: - App

final class AppDelegate: NSObject, NSApplicationDelegate {
    let store = Store()
    var catPanel: NSPanel!
    var catView: CatView!
    var bubblePanel: KeyPanel!
    var bubble: BubbleView!
    var quipPanel: NSPanel!
    var quip: QuipView!
    var quipToken = 0
    var quipsOn = false  // 고양이가 혼자 한마디씩 하는 작은 말풍선

    var wanderOn = true
    var motion: Timer?   // 걷기나 점프가 진행 중일 때만 있음
    var perch: Perch?    // nil 이면 바닥
    var homeY: CGFloat = 0  // 바닥 높이 (드래그해서 놓은 곳)
    var creeping = false    // 창 위에서 숨은 채로 천천히 옮겨 가는 중
    var sitUpUntil = Date.distantPast  // 이 시각까지는 숨지 않고 올라앉아 있음

    var bowlPanel: NSPanel!
    var bowl: BowlView!
    var bowlHeld = false
    var eating = false
    var asleep = false
    var snoreTimer: Timer?
    var lastFollow = Date.distantPast

    // 콘솔에서 바꿀 수 있는 값들
    var runSpeed: CGFloat = 3.6   // 뛸 때 한 틱(0.05초)에 가는 거리
    var pace: Double = 9.5        // 다음 행동까지 평균 몇 초
    var climbChance = 55          // 바닥에 있을 때 창으로 올라갈 확률 (%)
    var sleepChance = 12          // 행동을 고를 때 잠들 확률 (%)
    var followChance = 30         // 마우스가 근처에 있을 때 1초마다 따라갈 확률 (%)
    var feedOnDone = true         // 할 일을 끝내면 밥을 준다
    var hub: Hub!                 // 본 창, 메뉴 막대, 상태 아이콘
    var hunger: Double = 20       // 0(배부름) ~ 100(몹시 배고픔)
    var bowlPerchOffset: CGFloat? // 창 위에 놓인 밥그릇이 창 왼쪽 끝에서 떨어진 거리

    enum FocusPhase { case idle, focus, rest }
    var focusPhase = FocusPhase.idle
    var focusEnds: Date?                 // 달리는 중이면 끝나는 시각
    var focusRemaining: TimeInterval = 0 // 멈춰 있을 때 남은 시간
    var focusMinutes = 25
    var breakMinutes = 5
    var seconds = 0

    var ballPanel: NSPanel!
    var ball: BallView!
    var ballTimer: Timer?
    var ballV = NSPoint.zero  // 한 틱에 움직이는 거리
    var ballHeld = false
    var playing = false
    var ballToken = 0

    var hasFood: Bool { bowlPanel.isVisible && !bowlHeld && bowl.stage < bowlStages.count - 1 }

    var bodyHeight: CGFloat { CGFloat(catView.design.rows.count) * catView.px }
    // 앞발을 걸치고 있을 때는 창을 그만큼 내려서 발이 모서리 아래로 나오게 한다
    var peekDrop: CGFloat { catView.inPeek ? CGFloat(pawOverhang) * catView.px : 0 }
    var idle: Bool { motion == nil && !asleep && !playing && !away && !catView.isBusy && !bubblePanel.isVisible }

    // 공놀이나 알림 때문에 바닥 줄을 떠나 화면 어딘가에 떠 있는 상태. 이때 있는 곳을 바닥으로 저장하면 안 된다
    var away = false
    var ringing = false
    var ringTimer: Timer?
    var ringToken = 0
    var awayUntil = Date.distantPast  // 이 시각까지는 떠 있는 채로 둔다 (말하는 중)

    func applicationDidFinishLaunching(_ notification: Notification) {
        let d = UserDefaults.standard
        catView = CatView(frame: .zero)
        let pick = d.object(forKey: "design") != nil ? d.integer(forKey: "design") : 2
        catView.design = designs[min(max(pick, 0), designs.count - 1)]
        catView.px = d.object(forKey: "px") != nil ? CGFloat(d.double(forKey: "px")) : 3
        let size = catView.spriteSize
        catView.setFrameSize(size)

        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1200, height: 800)
        var origin = NSPoint(x: screen.maxX - size.width - 60, y: screen.minY)
        if d.object(forKey: "catX") != nil {
            let saved = NSPoint(x: d.double(forKey: "catX"), y: d.double(forKey: "catY"))
            let frame = NSRect(origin: saved, size: size)
            if NSScreen.screens.contains(where: { $0.frame.intersects(frame) }) { origin = saved }
        }
        homeY = origin.y

        catPanel = NSPanel(contentRect: NSRect(origin: origin, size: size),
                           styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        configure(catPanel)
        catView.onClick = { [weak self] clicks in
            guard let self else { return }
            if self.ringing {  // 울리는 중이면 클릭은 소리 끄기
                self.stopRinging()
            } else if self.asleep {
                if clicks >= 2 { self.wake() }  // 자는 고양이는 더블클릭해야 깬다
            } else if clicks == 1 {
                self.toggleBubble()
            }
        }
        catView.onPet = { [weak self] in self?.showHeart() }
        catView.onMove = { [weak self] in self?.catDragged() }
        catView.menuProvider = { [weak self] in self?.makeMenu() ?? NSMenu() }
        catPanel.contentView = catView
        catPanel.orderFrontRegardless()

        bubble = BubbleView(store: store)
        bubble.onChange = { [weak self] in self?.layoutBubble() }
        bubblePanel = KeyPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel],
                               backing: .buffered, defer: false)
        configure(bubblePanel)
        bubblePanel.becomesKeyOnlyIfNeeded = true
        bubblePanel.appearance = NSAppearance(named: .aqua)
        bubblePanel.contentView = bubble

        quip = QuipView(frame: .zero)
        quipPanel = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel],
                            backing: .buffered, defer: false)
        configure(quipPanel)
        quipPanel.ignoresMouseEvents = true
        quipPanel.contentView = quip

        bowl = BowlView(frame: .zero)
        bowl.onGrab = { [weak self] in
            guard let self else { return }
            self.bowlHeld = true
            if self.eating { self.cancelMotion() }
        }
        bowl.onDrop = { [weak self] _ in
            self?.bowlHeld = false
            self?.goEat()
        }
        bowlPanel = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel],
                            backing: .buffered, defer: false)
        configure(bowlPanel)
        bowlPanel.contentView = bowl

        ball = BallView(frame: .zero)
        ball.onGrab = { [weak self] in
            self?.ballHeld = true
            self?.ballV = .zero
        }
        ball.onDrop = { [weak self] v in self?.throwBall(velocity: v) }
        ballPanel = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel],
                            backing: .buffered, defer: false)
        configure(ballPanel)
        ballPanel.contentView = ball

        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(appActivated(_:)),
            name: NSWorkspace.didActivateApplicationNotification, object: nil)
        let follower = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in self?.follow() }
        RunLoop.main.add(follower, forMode: .common)
        let watcher = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            self?.watchMouse()
            self?.everySecond()
        }
        RunLoop.main.add(watcher, forMode: .common)

        wanderOn = d.object(forKey: "wander") == nil || d.bool(forKey: "wander")
        quipsOn = d.bool(forKey: "quips")
        if d.object(forKey: "runSpeed") != nil { runSpeed = CGFloat(d.double(forKey: "runSpeed")) }
        if d.object(forKey: "pace") != nil { pace = max(2, d.double(forKey: "pace")) }
        if d.object(forKey: "climbChance") != nil { climbChance = d.integer(forKey: "climbChance") }
        if d.object(forKey: "sleepChance") != nil { sleepChance = d.integer(forKey: "sleepChance") }
        if d.object(forKey: "followChance") != nil { followChance = d.integer(forKey: "followChance") }
        feedOnDone = d.object(forKey: "feedOnDone") == nil || d.bool(forKey: "feedOnDone")
        store.onChange = { [weak self] old, new in self?.todosChanged(old, new) }
        scheduleBlink()
        scheduleWag()
        scheduleAct()

        if d.object(forKey: "hunger") != nil {
            // 꺼져 있던 동안에도 배는 고파진다
            let away = Date().timeIntervalSince1970 - d.double(forKey: "hungerAt")
            hunger = min(100, d.double(forKey: "hunger") + max(0, away) / 360)
        }
        if d.object(forKey: "focusMinutes") != nil { focusMinutes = max(1, d.integer(forKey: "focusMinutes")) }
        if d.object(forKey: "breakMinutes") != nil { breakMinutes = max(1, d.integer(forKey: "breakMinutes")) }
        hub = Hub(app: self)
        bubble.notes = hub.notesPane
        hub.notesPane.onChange = { [weak self] in
            guard let self, self.bubblePanel.isVisible, self.bubble.showsNotes else { return }
            self.layoutBubble()
        }
        hub.install()

        // 메뉴를 누른 것과 똑같은 경로로 시험해 볼 수 있게
        let env = ProcessInfo.processInfo.environment
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            if let dir = env["PIXELCAT_TEST_HUB"] { self?.hub.snapshotAll(to: dir) }
            if env["PIXELCAT_TEST_BALL"] != nil { self?.toggleBall() }
            if env["PIXELCAT_TEST_FOOD"] != nil { self?.putFood() }
            if env["PIXELCAT_TEST_REMIND"] != nil { self?.comeAndSay("Time for: test reminder") }
            if env["PIXELCAT_TEST_DUE"] != nil {
                log("set due via popover path: \(self?.hub.testSetDue(after: 6) ?? false)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 22) {  // 시험이 끝나면 원래대로
                    self?.stopRinging()
                    if self?.store.todos.isEmpty == false {
                        self?.store.todos[0].due = nil
                        self?.store.todos[0].notified = nil
                    }
                    log("test due cleared")
                }
            }
            if env["PIXELCAT_TEST_TIMER"] != nil {  // 5초짜리 타이머를 돌려 본다
                self?.hub.timersPane.start(seconds: 5, label: "__test")
                log("test timer started")
                DispatchQueue.main.asyncAfter(deadline: .now() + 14) {
                    self?.stopRinging()
                    log("test over, timers left: \(self?.hub.timersPane.timers.count ?? -1)")
                }
            }
        }
    }

    func configure(_ panel: NSPanel) {
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        // 메뉴 막대보다 위. 화면을 꽉 채운 창 위(메뉴 막대 자리)에도 앉을 수 있게
        panel.level = NSWindow.Level(rawValue: NSWindow.Level.statusBar.rawValue + 1)
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
    }

    // MARK: Bubbles

    func toggleBubble() {
        if bubblePanel.isVisible {
            bubblePanel.orderOut(nil)
        } else {
            hideQuip()
            layoutBubble()
            bubblePanel.orderFrontRegardless()
        }
    }

    func layoutBubble() {
        let size = bubble.neededSize
        let cat = catPanel.frame
        let screen = (catPanel.screen ?? NSScreen.main)?.visibleFrame ?? cat
        var x = cat.midX - size.width / 2
        x = min(max(x, screen.minX + 4), screen.maxX - size.width - 4)
        var y = cat.minY + bodyHeight + 3
        var below = false
        if y + size.height > screen.maxY {
            y = cat.minY - size.height - 3
            below = true
        }
        bubble.tailOnTop = below
        bubble.tailX = min(max(cat.midX - x - BubbleView.u * 2, 12), size.width - 24)
        bubblePanel.setFrame(NSRect(x: x, y: y, width: size.width, height: size.height), display: false)
        bubble.rebuild()
    }

    // force 면 혼잣말을 꺼 놔도 띄운다 (알림처럼 꼭 전해야 하는 말)
    func say(_ text: String, force: Bool = false, seconds: Double = 2.4) {
        guard quipsOn || force else { return }
        if bubblePanel.isVisible {
            guard force else { return }
            bubblePanel.orderOut(nil)
        }
        sitUpUntil = max(sitUpUntil, Date() + seconds + 0.2)
        quip.showsHeart = false
        quip.text = text
        showQuip(for: seconds)
    }

    // 쓰다듬으면 뜨는 하트. 혼잣말을 꺼 놔도 뜬다
    func showHeart() {
        guard !asleep, !bubblePanel.isVisible else { return }
        quip.showsHeart = true
        showQuip(for: 1.6)
    }

    func showQuip(for seconds: Double) {
        let size = quip.neededSize
        let cat = catPanel.frame
        quipPanel.setFrame(NSRect(x: cat.midX - size.width / 2, y: cat.minY + bodyHeight + 3,
                                  width: size.width, height: size.height), display: true)
        quipPanel.orderFrontRegardless()
        quipToken += 1
        let token = quipToken
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
            if self?.quipToken == token { self?.quipPanel.orderOut(nil) }
        }
    }

    func hideQuip() {
        quipToken += 1
        quipPanel.orderOut(nil)
    }

    func nagLine() -> String {
        let left = store.todos.filter { !$0.done }.count
        var lines = ["Whatcha doing?", "Let me see", "Play with me", "My spot now"]
        if left > 0 { lines += ["\(left) to-do\(left == 1 ? "" : "s") left, meow", "Did you finish your to-dos?"] }
        return lines.randomElement()!
    }

    // MARK: Position

    func saveHome() {
        homeY = catPanel.frame.minY
        UserDefaults.standard.set(Double(catPanel.frame.minX), forKey: "catX")
        UserDefaults.standard.set(Double(homeY), forKey: "catY")
    }

    // 손으로 끌어다 놓으면 거기가 새 바닥
    func catDragged() {
        away = false  // 손으로 놓은 곳이 새 바닥
        catView.standUp()
        cancelMotion()
        perch = nil
        hideQuip()
        saveHome()
        if bubblePanel.isVisible { layoutBubble() }
    }

    func moveCat(to origin: NSPoint) {
        guard origin != catPanel.frame.origin else { return }
        catPanel.setFrameOrigin(origin)
        if bubblePanel.isVisible { layoutBubble() }
    }

    // 올라앉은 창이 움직이면 따라가고, 창이 사라지거나 가려지면 바닥으로 내려온다
    func follow() {
        guard let p = perch, !catView.pressed else {
            catView.sinkTarget = 0
            return
        }
        // 창 위에서는 기본이 빼꼼. 건드리거나 말할 때, 뛸 때만 올라온다
        let hiding = (motion == nil || creeping) && !bubblePanel.isVisible && !hasFood && Date() > sitUpUntil
        catView.sinkTarget = hiding ? catView.hideDepth : 0
        let wins = visibleWindows()
        guard let i = wins.firstIndex(where: { $0.id == p.id }) else {
            log("perch window gone")
            dropToFloor()
            return
        }
        let f = wins[i].frame
        if f != p.bounds {
            perch?.bounds = f
            cancelMotion()
        }
        guard motion == nil else { return }

        let catW = catPanel.frame.width
        var x = min(max(f.minX + p.offsetX, f.minX), max(f.minX, f.maxX - catW))
        // 창이 움직여서 노치 밑으로 들어가게 되면 가까운 쪽 옆으로 비켜 앉는다
        if let notch = notchRange(atY: f.maxY, height: bodyHeight), x + catW > notch.lowerBound, x < notch.upperBound {
            let goLeft = x + catW / 2 < (notch.lowerBound + notch.upperBound) / 2
            x = goLeft ? notch.lowerBound - catW : notch.upperBound
            perch?.offsetX = x - f.minX
        }
        let foot = NSPoint(x: x + catW / 2, y: f.maxY - 2)
        let onScreen = NSScreen.screens.contains { $0.frame.contains(NSPoint(x: foot.x, y: f.maxY + bodyHeight - 1)) }
        if !onScreen || wins[..<i].contains(where: { $0.frame.contains(foot) }) {
            log("perch covered or off screen")
            dropToFloor()
            return
        }
        if let offset = bowlPerchOffset, bowlPanel.isVisible, !bowlHeld {
            let spot = NSPoint(x: f.minX + offset, y: f.maxY)
            if spot != bowlPanel.frame.origin { bowlPanel.setFrameOrigin(spot) }
        }
        let target = NSPoint(x: x, y: f.maxY - peekDrop)
        hideQuipIfMoved(to: target)
        moveCat(to: target)
    }

    func hideQuipIfMoved(to origin: NSPoint) {
        if origin != catPanel.frame.origin { hideQuip() }
    }

    // MARK: Motion

    // 뛸 때는 다리 그림을 순서대로 넘기고, 걸을 때는 두 박자로 들썩인다
    func stepFrame(_ tick: Int, run: Bool) -> Int {
        run ? (tick / 2) % max(catView.design.legs.count, 2) + 1 : (tick / 6) % 2 + 1
    }

    func cancelMotion() {
        motion?.invalidate()
        motion = nil
        catView.walkFrame = 0
        catView.running = false
        catView.jump = 0
        catView.dip = 0
        catView.wag = false
        creeping = false
        if eating {
            eating = false
            catView.happy = false
        }
    }

    // run 이면 다리를 내고 빠르게 뛰고, 아니면 식빵 자세 그대로 천천히 들썩이며 간다
    func walk(to targetX: CGFloat, run: Bool = false, then done: (() -> Void)? = nil) {
        cancelMotion()
        wake()
        hideQuip()
        let speed: CGFloat = run ? runSpeed : 1.2
        catView.running = run
        creeping = !run && perch != nil
        catView.facingRight = targetX > catPanel.frame.minX
        var x = catPanel.frame.minX  // 창 좌표는 반올림되므로 위치는 따로 누적한다
        var tick = 0
        let t = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self else { return }
            var o = self.catPanel.frame.origin
            if abs(o.x - x) > 3 {  // 다른 무언가가 고양이를 옮겼으면 걷는 시늉만 하지 말고 멈춘다
                log("walk interrupted: window at \(o.x), expected \(x)")
                self.cancelMotion()
                return
            }
            o.x = x
            let left = abs(targetX - o.x)
            let arrived = left < 0.5
            if arrived || self.catView.isBusy || self.bubblePanel.isVisible {
                self.cancelMotion()
                if self.perch == nil && !self.away { self.saveHome() }
                if arrived { done?() }
                return
            }
            tick += 1
            o.x += (targetX > o.x ? 1 : -1) * min(speed, left)
            x = o.x
            self.catPanel.setFrameOrigin(o)
            if let b = self.perch?.bounds { self.perch?.offsetX = o.x - b.minX }
            let frame = self.stepFrame(tick, run: run)
            self.catView.walkFrame = frame
            if run { self.catView.jump = frame == 1 ? 1 : 0 }  // 쭉 뻗을 때는 살짝 떠 있음
            if tick % 8 == 0 { self.catView.wag.toggle() }
        }
        RunLoop.main.add(t, forMode: .common)
        motion = t
    }

    // 포물선으로 뛰어서 이동. landing 이 있으면 그 창 위에 앉고, 없으면 바닥에 내린다
    func jump(to target: NSPoint, landing: Perch? = nil, then done: (() -> Void)? = nil) {
        cancelMotion()
        wake()
        hideQuip()
        perch = nil
        var start = catPanel.frame.origin
        start.y += peekDrop
        catView.standUp()
        let dist = hypot(target.x - start.x, target.y - start.y)
        // 거리에 맞춰 시간을 늘린다 (뛰는 속도의 2.5배쯤). 멀리 갈 때 순간이동처럼 보이지 않게
        let frames = max(18, min(120, Int(dist / (runSpeed * 2.5))))
        let peak = min(140, 30 + dist * 0.12)
        catView.facingRight = target.x > start.x
        catView.running = true
        catView.walkFrame = 1
        var n = 0
        let t = Timer(timeInterval: 0.03, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.catView.pressed {  // 공중에서 붙잡힘
                self.cancelMotion()
                self.away = true
                return
            }
            n += 1
            self.catView.walkFrame = self.stepFrame(n, run: true)  // 공중에서도 발을 구른다
            let k = CGFloat(n) / CGFloat(frames)
            self.moveCat(to: NSPoint(x: start.x + (target.x - start.x) * k,
                                     y: start.y + (target.y - start.y) * k + peak * 4 * k * (1 - k)))
            if n >= frames {
                self.cancelMotion()
                self.perch = landing
                self.away = false
                self.sitUpUntil = Date() + 0.6
                if landing == nil { self.saveHome() }
                self.catView.hop([1, 2, 1, 0])
                done?()
            }
        }
        RunLoop.main.add(t, forMode: .common)
        motion = t
    }

    func dropToFloor(then done: (() -> Void)? = nil) {
        perch = nil
        let cat = catPanel.frame
        let screen = (NSScreen.screens.first { $0.frame.contains(NSPoint(x: cat.midX, y: homeY + 1)) }
            ?? NSScreen.main)?.visibleFrame ?? cat
        let x = min(max(cat.minX, screen.minX), screen.maxX - cat.width)
        log("drop to floor")
        jump(to: NSPoint(x: x, y: homeY), then: done)
    }

    // wins[i] 창 윗변에서 다른 창에 가려지지 않은 자리를 고른다
    func spot(on i: Int, in wins: [Win]) -> NSPoint? {
        let w = wins[i].frame
        let catW = catPanel.frame.width
        guard let full = NSScreen.screens.first(where: { $0.frame.contains(NSPoint(x: w.midX, y: w.maxY - 1)) }),
              w.maxY + bodyHeight <= full.frame.maxY, w.maxY > full.visibleFrame.minY + bodyHeight else { return nil }
        let screen = full.visibleFrame
        let lo = max(w.minX, screen.minX), hi = min(w.maxX, screen.maxX) - catW
        guard hi > lo else { return nil }
        let notch = notchRange(atY: w.maxY, height: bodyHeight)
        for _ in 0..<12 {
            let x = CGFloat.random(in: lo...hi)
            if let notch = notch, x + catW > notch.lowerBound, x < notch.upperBound { continue }  // 노치 밑은 피한다
            let foot = NSPoint(x: x + catW / 2, y: w.maxY - 2)
            if !wins[..<i].contains(where: { $0.frame.contains(foot) }) { return NSPoint(x: x, y: w.maxY) }
        }
        return nil
    }

    @discardableResult
    func hopOntoWindow(frontOnly: Bool, then done: (() -> Void)? = nil) -> Bool {
        let wins = visibleWindows()
        let candidates = frontOnly ? Array(wins.indices.prefix(1)) : Array(wins.indices.prefix(6)).shuffled()
        for i in candidates {
            if frontOnly && perch?.id == wins[i].id { return false }
            guard let p = spot(on: i, in: wins) else { continue }
            log("hop onto window \(wins[i].id) at \(p)")
            jump(to: p, landing: Perch(id: wins[i].id, bounds: wins[i].frame, offsetX: p.x - wins[i].frame.minX),
                 then: done)
            return true
        }
        return false
    }

    var walkRange: ClosedRange<CGFloat>? {
        let catW = catPanel.frame.width
        guard let screen = (catPanel.screen ?? NSScreen.main)?.visibleFrame else { return nil }
        var lo = screen.minX, hi = screen.maxX - catW
        if let b = perch?.bounds {
            lo = max(lo, b.minX)
            hi = min(hi, b.maxX - catW)
        }
        return hi > lo ? lo...hi : nil
    }

    func stroll(allowRun: Bool = true) {
        guard let range = walkRange else { return }
        let start = catPanel.frame.minX
        let run = allowRun && Int.random(in: 0..<4) == 0  // 가끔은 우다다
        let distance = (run ? CGFloat.random(in: 250...600) : CGFloat.random(in: 60...220)) * (Bool.random() ? 1 : -1)
        var target = start + distance
        if !range.contains(target) { target = start - distance }
        walk(to: min(max(target, range.lowerBound), range.upperBound), run: run)
    }

    // 마우스 쪽으로 후다닥 달려간다
    func chaseMouse() {
        guard let range = walkRange else { return }
        let target = min(max(NSEvent.mouseLocation.x - catPanel.frame.width / 2, range.lowerBound), range.upperBound)
        log("chase mouse to \(target)")
        if abs(target - catPanel.frame.minX) < 30 {
            catView.hop([1, 3, 4, 3, 1, 0])
            say("Mew!")
        } else {
            walk(to: target, run: true) { [weak self] in
                self?.catView.hop([1, 3, 4, 3, 1, 0])
                self?.say(["Gotcha!", "Where you going?", "What's that?"].randomElement()!)
            }
        }
    }

    // MARK: Food

    // 밥그릇을 고양이가 서 있는 줄 위, 조금 떨어진 곳에 놓는다. 놓인 그릇은 손으로 끌어서 옮길 수 있다
    @objc func putFood() {
        if eating { cancelMotion() }
        bowlHeld = false
        bowl.stage = 0
        bowl.px = catView.px
        bowlPanel.setContentSize(bowl.neededSize)
        let cat = catPanel.frame
        let screen = (catPanel.screen ?? NSScreen.main)?.visibleFrame ?? cat
        let gap: CGFloat = 170
        let roomLeft = cat.minX - screen.minX, roomRight = screen.maxX - cat.maxX
        let x = roomLeft > roomRight ? cat.minX - gap : cat.maxX + gap - bowl.neededSize.width
        bowlPanel.setFrameOrigin(NSPoint(x: min(max(x, screen.minX), screen.maxX - bowl.neededSize.width),
                                         y: away ? homeY : cat.minY + peekDrop))
        bowlPanel.orderFrontRegardless()
        log("food placed at \(bowlPanel.frame.origin)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in self?.goEat() }
    }

    // 밥그릇 옆으로 걸어간다 (멀면 뛴다). 점프는 하지 않도록 밥그릇을 고양이가 서 있는 줄로 옮겨 놓는다
    func goEat() {
        guard hasFood, !playing, !away, motion == nil, !catView.pressed else { return }
        wake()
        if catView.inPeek {
            catPanel.setFrameOrigin(NSPoint(x: catPanel.frame.minX, y: catPanel.frame.minY + peekDrop))
            catView.standUp()
        }
        let cat = catPanel.frame
        guard let range = walkRange else { return }
        var b = bowlPanel.frame
        b.origin.x = min(max(b.minX, range.lowerBound), range.upperBound + cat.width - b.width)
        b.origin.y = cat.minY
        bowlPanel.setFrameOrigin(b.origin)
        bowlPerchOffset = perch.map { b.minX - $0.bounds.minX }  // 창 위라면 창을 따라다니게 기억해 둔다

        let overlap = 2 * catView.px
        var fromRight = cat.midX > b.midX
        func spotX(_ fromRight: Bool) -> CGFloat { fromRight ? b.maxX - overlap : b.minX - cat.width + overlap }
        if !range.contains(spotX(fromRight)) && range.contains(spotX(!fromRight)) { fromRight.toggle() }
        let x = min(max(spotX(fromRight), range.lowerBound), range.upperBound)
        if abs(cat.minX - x) < 1.5 {
            eat(facingRight: !fromRight)
        } else {
            log("going to food at \(x)")
            walk(to: x, run: abs(cat.minX - x) > 300) { [weak self] in self?.goEat() }
        }
    }

    func eat(facingRight: Bool) {
        cancelMotion()
        wake()
        log("eating")
        eating = true
        catView.facingRight = facingRight
        catView.happy = true
        say("Nom nom")
        var tick = 0
        let t = Timer(timeInterval: 0.18, repeats: true) { [weak self] _ in
            guard let self else { return }
            tick += 1
            self.catView.dip = tick % 2  // 고개 까딱까딱
            if tick % 8 == 0 { self.bowl.stage += 1 }
            if self.bowl.stage >= bowlStages.count - 1 { self.finishEating() }
        }
        RunLoop.main.add(t, forMode: .common)
        motion = t
    }

    func finishEating() {
        cancelMotion()
        log("finished eating")
        catView.hop([0, 0, 0, 0, 0, 0])
        say(["Yummy!", "That was good", "Any more?"].randomElement()!)
        hunger = max(0, hunger - 70)
        saveHunger()
        hub.refresh()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { [weak self] in
            guard let self else { return }
            if !self.bowlHeld && !self.hasFood { self.bowlPanel.orderOut(nil) }
        }
    }

    // MARK: Yarn ball

    @objc func toggleBall() {
        defer { hub.refresh() }
        if ballPanel.isVisible {
            stopPlay()
            ballPanel.orderOut(nil)
            return
        }
        ball.px = catView.px
        ballPanel.setContentSize(ball.neededSize)
        let cat = catPanel.frame
        ballPanel.setFrameOrigin(NSPoint(x: cat.midX, y: cat.minY + bodyHeight + 20))
        ballPanel.orderFrontRegardless()
        let angle = CGFloat.random(in: 0.25...0.75) * .pi  // 위쪽으로 툭
        throwBall(velocity: NSPoint(x: cos(angle) * 400, y: sin(angle) * 400))
    }

    // 공을 놓거나 던졌을 때. 놀고 있지 않았으면 놀이를 시작한다
    func throwBall(velocity: NSPoint) {
        ballHeld = false
        var v = NSPoint(x: velocity.x * 0.03, y: velocity.y * 0.03)
        let speed = hypot(v.x, v.y)
        if speed > 26 { v = NSPoint(x: v.x / speed * 26, y: v.y / speed * 26) }
        ballV = v
        ballToken += 1
        log("ball thrown \(v)")
        if !playing { startPlay() }
    }

    // 공은 화면 안을 자유롭게 굴러다니며 가장자리에서 튄다. 고양이는 어디든 쫓아가서 앞발로 쳐 내고,
    // 충분히 놀면 만족해서 원래 있던 높이로 돌아간다
    func startPlay() {
        wake()
        if eating { cancelMotion() }
        if catView.inPeek {
            catPanel.setFrameOrigin(NSPoint(x: catPanel.frame.minX, y: catPanel.frame.minY + peekDrop))
        }
        catView.standUp()
        cancelMotion()
        perch = nil
        playing = true
        away = true

        let size = ballPanel.frame.size
        var pos = ballPanel.frame.origin
        var spin: CGFloat = 0
        var tick = 0
        var bats = 0
        let goal = Int.random(in: 12...18)
        var restUntil = Date.distantPast
        var chasing = false

        let t = Timer(timeInterval: 0.03, repeats: true) { [weak self] _ in
            guard let self else { return }
            tick += 1

            if self.ballHeld {
                pos = self.ballPanel.frame.origin
            } else {
                let screen = (NSScreen.screens.first {
                    $0.frame.contains(NSPoint(x: pos.x + size.width / 2, y: pos.y + size.height / 2))
                } ?? NSScreen.main)?.visibleFrame ?? self.catPanel.frame
                var v = self.ballV
                pos.x += v.x
                pos.y += v.y
                if pos.x < screen.minX { pos.x = screen.minX; v.x = abs(v.x) * 0.9 }
                if pos.x > screen.maxX - size.width { pos.x = screen.maxX - size.width; v.x = -abs(v.x) * 0.9 }
                if pos.y < screen.minY { pos.y = screen.minY; v.y = abs(v.y) * 0.9 }
                if pos.y > screen.maxY - size.height { pos.y = screen.maxY - size.height; v.y = -abs(v.y) * 0.9 }
                v.x *= 0.985
                v.y *= 0.985
                if hypot(v.x, v.y) < 0.25 { v = .zero }
                self.ballV = v
                spin += hypot(v.x, v.y)
                self.ball.frameIndex = Int(spin / 10)
                self.ballPanel.setFrameOrigin(pos)
            }

            func rest() {
                guard chasing else { return }
                chasing = false
                self.catView.walkFrame = 0
                self.catView.running = false
                self.catView.jump = 0
            }
            if tick > 6000 {  // 3분이 지나면 그만
                rest()
                self.stopPlay()
                return
            }
            // 붙잡혀 있거나 할 일 창이 열려 있으면 공만 굴러간다. 공을 손에 들고 있을 때도 기다린다
            guard self.motion == nil, !self.catView.pressed, !self.bubblePanel.isVisible, !self.ballHeld,
                  Date() > restUntil else {
                rest()
                return
            }
            var cat = self.catPanel.frame
            let ballCenter = NSPoint(x: pos.x + size.width / 2, y: pos.y + size.height / 2)
            if abs(ballCenter.x - cat.midX) > 8 { self.catView.facingRight = ballCenter.x > cat.midX }
            let reach = self.catView.px * 3
            let head = NSPoint(x: self.catView.facingRight ? cat.maxX - reach : cat.minX + reach,
                               y: cat.minY + self.bodyHeight / 2)
            let dx = ballCenter.x - head.x, dy = ballCenter.y - head.y
            let dist = hypot(dx, dy)
            if dist < 12 {
                bats += 1
                log("bat \(bats)/\(goal)")
                rest()
                if bats >= goal {
                    self.stopPlay(caught: true)
                    return
                }
                // 고양이 반대쪽으로, 좌우로 조금 빗나가게 쳐 낸다
                let away = atan2(ballCenter.y - (cat.minY + self.bodyHeight / 2), ballCenter.x - cat.midX)
                let angle = away + CGFloat.random(in: -1.0...1.0)
                let power = CGFloat.random(in: 10...17)
                self.ballV = NSPoint(x: cos(angle) * power, y: sin(angle) * power)
                restUntil = Date() + 0.3
                return
            }
            chasing = true
            self.catView.running = true
            let step = min(self.runSpeed * 1.28, dist)
            cat.origin.x += dx / dist * step
            cat.origin.y += dy / dist * step
            self.catPanel.setFrameOrigin(cat.origin)
            let frame = self.stepFrame(tick, run: true)
            self.catView.walkFrame = frame
            self.catView.jump = frame == 1 ? 1 : 0
        }
        RunLoop.main.add(t, forMode: .common)
        ballTimer = t
    }

    func stopPlay(caught: Bool = false) {
        guard playing else { return }
        playing = false
        ballTimer?.invalidate()
        ballTimer = nil
        ballV = .zero
        catView.walkFrame = 0
        catView.running = false
        catView.jump = 0
        if caught {
            log("done playing")
            catView.hop([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
            say(["Got it!", "Mine now", "Throw it again"].randomElement()!)
        }
        // 공은 잠깐 남겨 둔다. 그사이 다시 집어서 던지면 또 논다
        ballToken += 1
        let token = ballToken
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) { [weak self] in
            guard let self, self.ballToken == token, !self.playing, !self.ballHeld else { return }
            self.ballPanel.orderOut(nil)
        }
        // 놀던 자리에서 원래 바닥 높이로 뛰어 돌아간다
        DispatchQueue.main.asyncAfter(deadline: .now() + (caught ? 1.2 : 0)) { [weak self] in
            guard let self, !self.playing, self.motion == nil, !self.catView.pressed else { return }
            self.runHome()
        }
    }

    // 공중에 떠 있는 고양이를 바닥 줄까지 곧장 달려서 데려온다 (점프 없이)
    func runHome() {
        let cat = catPanel.frame
        let screen = (NSScreen.screens.first { $0.frame.contains(NSPoint(x: cat.midX, y: homeY + 1)) }
            ?? NSScreen.main)?.visibleFrame ?? cat
        let target = NSPoint(x: min(max(cat.minX, screen.minX), screen.maxX - cat.width), y: homeY)
        guard hypot(target.x - cat.minX, target.y - cat.minY) > 1 else {
            away = false
            return
        }
        cancelMotion()
        var pos = cat.origin
        var tick = 0
        catView.running = true
        let t = Timer(timeInterval: 0.03, repeats: true) { [weak self] _ in
            guard let self else { return }
            let dx = target.x - pos.x, dy = target.y - pos.y
            let dist = hypot(dx, dy)
            if dist < 1 || self.catView.pressed {
                self.cancelMotion()
                if !self.catView.pressed {
                    self.away = false
                    self.saveHome()
                }
                return
            }
            tick += 1
            let step = min(self.runSpeed * 1.28, dist)
            pos.x += dx / dist * step
            pos.y += dy / dist * step
            self.moveCat(to: pos)
            let frame = self.stepFrame(tick, run: true)
            self.catView.walkFrame = frame
            self.catView.jump = frame == 1 ? 1 : 0
        }
        RunLoop.main.add(t, forMode: .common)
        motion = t
    }

    // MARK: Sleep

    func fallAsleep() {
        guard !asleep, motion == nil, !hasFood else { return }
        log("asleep")
        asleep = true
        catView.asleep = true
        hideQuip()
        let sizes = [0, 1, 2, 3, 3, 2, 1, 0]  // 숨 쉴 때마다 콧방울이 부풀었다 줄어든다
        var tick = 0
        let t = Timer(timeInterval: 0.4, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.bubblePanel.isVisible {
                self.wake()
                return
            }
            tick += 1
            self.catView.snot = sizes[tick % sizes.count]
        }
        RunLoop.main.add(t, forMode: .common)
        snoreTimer = t
    }

    func wake() {
        guard asleep else { return }
        log("awake")
        asleep = false
        catView.asleep = false
        catView.snot = 0
        snoreTimer?.invalidate()
        snoreTimer = nil
    }

    @objc func toggleSleep() {
        defer { hub.refresh() }
        if asleep {
            wake()
        } else {
            cancelMotion()
            fallAsleep()
        }
    }

    // 마우스가 근처에 오면 가끔 졸졸 따라다닌다. 멀면 뛰고 가까우면 걷고, 창 위에서는 매달린 채로 옮겨 간다
    func followMouse() {
        cancelMotion()
        hideQuip()
        log("follow mouse")
        creeping = perch != nil
        var tick = 0
        var run = false
        let t = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self else { return }
            tick += 1
            let cat = self.catPanel.frame
            let mouse = NSEvent.mouseLocation
            guard tick < 160, !self.catView.isBusy, !self.bubblePanel.isVisible, !self.hasFood,
                  let range = self.walkRange, abs(mouse.y - cat.minY) < 500 else {
                self.cancelMotion()
                self.lastFollow = Date()
                if self.perch == nil && !self.away { self.saveHome() }
                return
            }
            let target = min(max(mouse.x - cat.width / 2, range.lowerBound), range.upperBound)
            let left = abs(target - cat.minX)
            if left < 8 {  // 다 왔으면 앉아서 기다림
                self.catView.walkFrame = 0
                self.catView.running = false
                self.catView.jump = 0
                run = false
                return
            }
            if left > 200 { run = true } else if left < 60 { run = false }
            if self.perch != nil { run = false }
            self.catView.facingRight = target > cat.minX
            self.catView.running = run
            var o = cat.origin
            o.x += (target > o.x ? 1 : -1) * min(run ? self.runSpeed : 1.2, left)
            self.catPanel.setFrameOrigin(o)
            if let b = self.perch?.bounds { self.perch?.offsetX = o.x - b.minX }
            let frame = self.stepFrame(tick, run: run)
            self.catView.walkFrame = frame
            self.catView.jump = run && frame == 1 ? 1 : 0
        }
        RunLoop.main.add(t, forMode: .common)
        motion = t
    }

    func watchMouse() {
        guard wanderOn, idle, perch == nil, !hasFood, Date() > lastFollow + 8 else { return }
        let cat = catPanel.frame
        let mouse = NSEvent.mouseLocation
        let dist = hypot(mouse.x - cat.midX, mouse.y - (cat.minY + bodyHeight / 2))
        if dist > 50 && dist < 260 && Int.random(in: 0..<100) < followChance { followMouse() }
    }

    // MARK: Behaviour

    func scheduleAct() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .random(in: pace * 0.5...pace * 1.5)) { [weak self] in
            self?.act()
            self?.scheduleAct()
        }
    }

    func act() {
        if hasFood && !away {  // 밥이 있으면 다른 건 제쳐두고 먹으러 간다
            goEat()
            return
        }
        if playing { return }
        if away {  // 어쩌다 공중에 남았으면 제자리로 돌아간다
            if motion == nil && !catView.pressed && !bubblePanel.isVisible && Date() > awayUntil { runHome() }
            return
        }
        if asleep {  // 한 번 잠들면 평균 1~2분쯤 잔다. 집중 시간에는 끝날 때까지 잔다
            if !focusing && Int.random(in: 0..<100) < 10 { wake() }
            return
        }
        guard wanderOn, idle else { return }
        if focusing {
            fallAsleep()
            return
        }
        if hunger >= 75 && Int.random(in: 0..<100) < 35 {  // 배고프면 돌아다니는 대신 밥 달라고 한다
            say("I'm hungry…", force: true, seconds: 3)
            return
        }
        let roll = Int.random(in: 0..<100)
        if perch != nil {
            // 창 위에서는 거의 항상 매달려서 내다보고, 가끔만 움직인다
            if Int.random(in: 0..<100) < sleepChance / 2 {
                fallAsleep()
                return
            }
            switch roll {
            case ..<87: break
            case ..<90: sitUpUntil = Date() + 3  // 잠깐 올라와서 두리번
            case ..<94: if !hopOntoWindow(frontOnly: false) { dropToFloor() }
            default: dropToFloor()
            }
        } else if Int.random(in: 0..<100) < sleepChance {
            fallAsleep()
        } else if roll < climbChance && hopOntoWindow(frontOnly: false) {
            return
        } else if Int.random(in: 0..<100) < 25 {
            chaseMouse()
        } else {
            stroll()
        }
    }

    // 다른 앱으로 넘어가면 가끔 그 창 위로 따라와서 참견한다
    @objc func appActivated(_ note: Notification) {
        guard wanderOn, !hasFood, Int.random(in: 0..<100) < 60 else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            guard let self, self.wanderOn, self.idle, !self.hasFood else { return }
            self.hopOntoWindow(frontOnly: true) { [weak self] in
                guard let self else { return }
                self.say(self.nagLine())
            }
        }
    }

    // MARK: Menu

    func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(withTitle: "Open Pixel Cat…", action: #selector(openHub), keyEquivalent: "").target = self
        menu.addItem(.separator())
        let look = NSMenu()
        for (i, design) in designs.enumerated() {
            let item = look.addItem(withTitle: design.name, action: #selector(pickDesign(_:)), keyEquivalent: "")
            item.target = self
            item.tag = i
            item.state = design.name == catView.design.name ? .on : .off
        }
        menu.addItem(withTitle: "Change Cat", action: nil, keyEquivalent: "").submenu = look
        let size = NSMenu()
        for (i, s) in sizes.enumerated() {
            let item = size.addItem(withTitle: s.name, action: #selector(pickSize(_:)), keyEquivalent: "")
            item.target = self
            item.tag = i
            item.state = s.px == catView.px ? .on : .off
        }
        menu.addItem(withTitle: "Size", action: nil, keyEquivalent: "").submenu = size
        menu.addItem(withTitle: "Put Out Food", action: #selector(putFood), keyEquivalent: "").target = self
        menu.addItem(withTitle: ballPanel.isVisible ? "Put Away Yarn Ball" : "Throw Yarn Ball",
                     action: #selector(toggleBall), keyEquivalent: "").target = self
        menu.addItem(withTitle: asleep ? "Wake Up" : "Put to Sleep", action: #selector(toggleSleep), keyEquivalent: "").target = self
        let wander = menu.addItem(withTitle: "Wander Around", action: #selector(toggleWander), keyEquivalent: "")
        wander.target = self
        wander.state = wanderOn ? .on : .off
        let quips = menu.addItem(withTitle: "Cat Chatter", action: #selector(toggleQuips), keyEquivalent: "")
        quips.target = self
        quips.state = quipsOn ? .on : .off
        menu.addItem(.separator())
        menu.addItem(withTitle: "Clear Completed To-Dos", action: #selector(clearDone), keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "").target = self
        return menu
    }

    @objc func pickDesign(_ sender: NSMenuItem) {
        catView.design = designs[sender.tag]
        UserDefaults.standard.set(sender.tag, forKey: "design")
        resizeCat()
    }

    @objc func pickSize(_ sender: NSMenuItem) {
        catView.px = sizes[sender.tag].px
        UserDefaults.standard.set(Double(catView.px), forKey: "px")
        resizeCat()
    }

    // 발밑 가운데를 고정한 채로 창 크기를 맞춘다
    func resizeCat() {
        cancelMotion()
        if catView.inPeek {
            catPanel.setFrameOrigin(NSPoint(x: catPanel.frame.minX, y: catPanel.frame.minY + peekDrop))
            catView.standUp()
        }
        let old = catPanel.frame
        let size = catView.spriteSize
        catPanel.setFrame(NSRect(x: old.midX - size.width / 2, y: old.minY, width: size.width, height: size.height),
                          display: true)
        if perch == nil && !away { saveHome() }
        if bubblePanel.isVisible { layoutBubble() }
    }

    @objc func toggleQuips() {
        defer { hub.refresh() }
        quipsOn.toggle()
        UserDefaults.standard.set(quipsOn, forKey: "quips")
        if !quipsOn { hideQuip() }
    }

    @objc func toggleWander() {
        defer { hub.refresh() }
        wanderOn.toggle()
        UserDefaults.standard.set(wanderOn, forKey: "wander")
        if !wanderOn {
            cancelMotion()
            if perch != nil { dropToFloor() }
        }
    }

    @objc func clearDone() {
        store.todos.removeAll { $0.done }
        if bubblePanel.isVisible { layoutBubble() }
    }

    @objc func quit() { NSApp.terminate(nil) }

    // MARK: Hub hooks

    // 앱 아이콘을 다시 열면 본 창이 뜬다
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        hub.show()
        return true
    }

    @objc func openHub() { hub.show() }

    func everySecond() {
        seconds += 1
        watchMouse()
        focusTick()
        if seconds % 5 == 0 { checkDue() }
        if let text = hub.timersPane.fire(at: Date()) { ring(text) }
        if seconds % 60 == 0 {
            hunger = min(100, hunger + 100.0 / 600)  // 열 시간이면 완전히 배고파진다
            saveHunger()
        }
        hub.tick()
    }

    func setDesign(_ index: Int) {
        catView.design = designs[index]
        UserDefaults.standard.set(index, forKey: "design")
        resizeCat()
        hub.refresh()
    }

    func setSize(_ index: Int) {
        catView.px = sizes[index].px
        UserDefaults.standard.set(Double(catView.px), forKey: "px")
        resizeCat()
        hub.refresh()
    }

    func setTunable(_ key: String, _ value: Double) {
        let d = UserDefaults.standard
        switch key {
        case "runSpeed": runSpeed = CGFloat(value)
        case "pace": pace = value
        case "climbChance": climbChance = Int(value)
        case "sleepChance": sleepChance = Int(value)
        case "followChance": followChance = Int(value)
        default: return
        }
        d.set(value, forKey: key)
    }

    @objc func climbWindow() {
        guard perch == nil, !playing, !catView.pressed else { return }
        wake()
        cancelMotion()
        hopOntoWindow(frontOnly: false)
    }

    @objc func comeDown() {
        guard perch != nil, !catView.pressed else { return }
        dropToFloor()
    }

    @objc func toggleTodoBubble() {
        toggleBubble()
        hub.refresh()
    }

    // MARK: To-dos

    // 할 일이 바뀔 때마다 (고양이 말풍선에서든 본 창에서든) 불린다
    func todosChanged(_ old: [Todo], _ new: [Todo]) {
        let was = old.filter(\.done).count, now = new.filter(\.done).count
        if new.count >= old.count && now != was {  // 지워서 줄어든 건 세지 않는다
            var h = history
            h[dayKey(Date())] = max(0, (h[dayKey(Date())] ?? 0) + now - was)
            UserDefaults.standard.set(h, forKey: "history")
            if now > was { celebrate() }
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.hub.reloadTodos()
            if self.bubblePanel.isVisible { self.layoutBubble() }
        }
    }

    func dayKey(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    // 날짜별로 끝낸 할 일 개수
    var history: [String: Int] { UserDefaults.standard.dictionary(forKey: "history") as? [String: Int] ?? [:] }
    var doneToday: Int { history[dayKey(Date())] ?? 0 }

    // 오늘까지 하루도 빠짐없이 뭔가를 끝낸 날 수
    var streak: Int {
        let h = history
        var day = Date(), n = 0
        if (h[dayKey(day)] ?? 0) == 0 { day = day.addingTimeInterval(-86400) }  // 오늘 아직이면 어제까지로 센다
        while (h[dayKey(day)] ?? 0) > 0 {
            n += 1
            day = day.addingTimeInterval(-86400)
        }
        return n
    }

    // 할 일을 하나 끝내면 고양이가 좋아하고, 켜 두었으면 밥도 받는다
    func celebrate() {
        guard !asleep else { return }
        catView.hop(Array(repeating: 0, count: 30))
        showHeart()
        if feedOnDone && !bowlPanel.isVisible && !playing { putFood() }
    }

    @objc func toggleFeedOnDone() {
        feedOnDone.toggle()
        UserDefaults.standard.set(feedOnDone, forKey: "feedOnDone")
    }

    // MARK: Hunger and mood

    func saveHunger() {
        UserDefaults.standard.set(hunger, forKey: "hunger")
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "hungerAt")
    }

    // 지금 기분과 그 이유. 배고픔, 밀린 할 일, 오늘 끝낸 일로 정해진다
    var mood: (name: String, detail: String) {
        if asleep { return ("Sleeping", focusing ? "Napping while you focus" : "Double-click the cat to wake it") }
        if hunger >= 75 { return ("Hungry", "Finish a to-do or put out food") }
        let overdue = store.todos.filter { !$0.done && ($0.due ?? .distantFuture) < Date() }.count
        if overdue > 0 { return ("Worried", "\(overdue) to-do\(overdue == 1 ? " is" : "s are") overdue") }
        if doneToday > 0 && hunger < 45 { return ("Happy", "\(doneToday) finished today and well fed") }
        if playing { return ("Playful", "Chasing the yarn ball") }
        return ("Content", hunger < 45 ? "Fed and relaxed" : "Getting a little peckish")
    }

    // MARK: Reminders

    // 알림 시각이 된 할 일을 찾아서 고양이가 알려 준다
    func checkDue() {
        let now = Date()
        for i in store.todos.indices {
            let t = store.todos[i]
            guard !t.done, t.notified != true, let due = t.due, due <= now else { continue }
            store.todos[i].notified = true
            ring("Time for: \(t.text)")
            return  // 한 번에 하나씩
        }
    }

    // 소리를 내고, 고양이가 깨어나 마우스 커서가 있는 곳까지 화면을 가로질러 달려와서 말한다
    func comeAndSay(_ text: String, hold: Double = 9) {
        log("announce: \(text)")
        NSSound(named: "Glass")?.play()
        wake()
        if playing { stopPlay() }
        if catView.inPeek {
            catPanel.setFrameOrigin(NSPoint(x: catPanel.frame.minX, y: catPanel.frame.minY + peekDrop))
        }
        catView.standUp()
        cancelMotion()
        perch = nil
        away = true
        awayUntil = Date() + 30 + hold
        hideQuip()

        // 커서 바로 아래에 멈춘다. 커서를 가리거나 마우스가 올라간 것으로 치지 않게 조금 띄운다
        var pos = catPanel.frame.origin
        var tick = 0
        catView.running = true
        let t = Timer(timeInterval: 0.03, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.catView.pressed {
                self.cancelMotion()
                return
            }
            let mouse = NSEvent.mouseLocation
            let cat = self.catPanel.frame
            let screen = (NSScreen.screens.first { $0.frame.contains(mouse) } ?? NSScreen.main)?.visibleFrame ?? cat
            let target = NSPoint(
                x: min(max(mouse.x - cat.width / 2, screen.minX), screen.maxX - cat.width),
                y: min(max(mouse.y - self.bodyHeight - 14, screen.minY), screen.maxY - self.bodyHeight))
            let dx = target.x - pos.x, dy = target.y - pos.y
            let dist = hypot(dx, dy)
            tick += 1
            if dist < 4 || tick > 500 {  // 다 왔거나, 15초를 쫓아도 못 따라잡으면 그 자리에서 말한다
                self.cancelMotion()
                log("arrived at cursor")
                self.say(text, force: true, seconds: hold)
                self.awayUntil = Date() + hold + 1
                let token = self.ringToken
                DispatchQueue.main.asyncAfter(deadline: .now() + hold + 0.5) { [weak self] in
                    guard let self, self.ringToken == token, !self.ringing, self.motion == nil, !self.playing,
                          !self.catView.pressed, self.perch == nil else { return }
                    self.runHome()  // 할 말을 다 했으면 제자리로 돌아간다
                }
                return
            }
            if abs(dx) > 6 { self.catView.facingRight = dx > 0 }
            let step = min(self.runSpeed * 1.6, dist)
            pos.x += dx / dist * step
            pos.y += dy / dist * step
            self.moveCat(to: pos)
            let frame = self.stepFrame(tick, run: true)
            self.catView.walkFrame = frame
            self.catView.jump = frame == 1 ? 1 : 0
        }
        RunLoop.main.add(t, forMode: .common)
        motion = t
    }

    // MARK: Ringing

    // 타이머와 마감 알림: 고양이가 커서로 달려오고, 고양이를 클릭할 때까지(길어야 1분) 소리가 되풀이된다
    func ring(_ text: String) {
        log("ring: \(text)")
        stopRinging(returnHome: false)
        ringing = true
        ringToken += 1
        let token = ringToken
        var count = 0
        let t = Timer(timeInterval: 2.2, repeats: true) { [weak self] _ in
            guard let self, self.ringToken == token else { return }
            count += 1
            if count >= 27 {
                self.stopRinging()
            } else {
                NSSound(named: "Glass")?.play()
            }
        }
        RunLoop.main.add(t, forMode: .common)
        ringTimer = t
        comeAndSay(text, hold: 60)  // 첫 소리는 여기서 난다
        hub.refresh()
    }

    @objc func stopRinging(returnHome: Bool = true) {
        guard ringing else { return }
        log("ring stopped")
        ringing = false
        ringToken += 1
        ringTimer?.invalidate()
        ringTimer = nil
        hideQuip()
        awayUntil = .distantPast
        if returnHome && away && !playing && !catView.pressed {
            cancelMotion()
            runHome()
        }
        hub.refresh()
    }

    // MARK: Focus timer

    var focusing: Bool { focusPhase == .focus && focusEnds != nil }

    // 지금 단계에서 남은 시간
    var focusLeft: TimeInterval {
        if let ends = focusEnds { return max(0, ends.timeIntervalSinceNow) }
        return focusPhase == .idle ? TimeInterval(focusMinutes * 60) : focusRemaining
    }

    var focusSessionsToday: Int {
        (UserDefaults.standard.dictionary(forKey: "focusHistory") as? [String: Int])?[dayKey(Date())] ?? 0
    }

    // 시작, 멈춤, 이어서 하기를 한 버튼으로
    @objc func toggleFocus() {
        if let ends = focusEnds {  // 달리는 중 → 멈춤
            focusRemaining = max(0, ends.timeIntervalSinceNow)
            focusEnds = nil
            if focusPhase == .focus { wake() }
        } else {
            if focusPhase == .idle {
                focusPhase = .focus
                focusRemaining = TimeInterval(focusMinutes * 60)
            }
            focusEnds = Date() + focusRemaining
            if focusPhase == .focus { napForFocus() }
        }
        hub.refresh()
    }

    @objc func resetFocus() {
        let wasFocusing = focusing
        focusPhase = .idle
        focusEnds = nil
        focusRemaining = 0
        if wasFocusing { wake() }
        hub.refresh()
    }

    func setFocusLengths(focus: Int, rest: Int) {
        focusMinutes = focus
        breakMinutes = rest
        UserDefaults.standard.set(focus, forKey: "focusMinutes")
        UserDefaults.standard.set(rest, forKey: "breakMinutes")
        hub.refresh()
    }

    // 집중하는 동안 고양이는 방해하지 않고 잔다
    func napForFocus() {
        if playing { stopPlay() }
        guard !hasFood, !catView.pressed else { return }
        cancelMotion()
        fallAsleep()
    }

    func focusTick() {
        guard let ends = focusEnds, Date() >= ends else { return }
        if focusPhase == .focus {
            var h = UserDefaults.standard.dictionary(forKey: "focusHistory") as? [String: Int] ?? [:]
            h[dayKey(Date()), default: 0] += 1
            UserDefaults.standard.set(h, forKey: "focusHistory")
            focusPhase = .rest
            focusRemaining = TimeInterval(breakMinutes * 60)
            focusEnds = Date() + focusRemaining
            comeAndSay("Focus done! Take a \(breakMinutes)-minute break")
        } else {
            focusPhase = .idle
            focusEnds = nil
            comeAndSay("Break's over. Ready for another?")
        }
        hub.refresh()
    }

    // MARK: Idle animation

    func scheduleBlink() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .random(in: 2.5...6)) { [weak self] in
            self?.catView.blink = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self?.catView.blink = false
                self?.scheduleBlink()
            }
        }
    }

    func scheduleWag(step: Int = 0) {
        let delay = step == 0 ? Double.random(in: 3...8) : 0.25
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.catView.wag = step % 2 == 0
            self?.scheduleWag(step: (step + 1) % 4)
        }
    }
}

func writePNG(_ view: NSView, _ path: String) {
    guard let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return }
    view.cacheDisplay(in: view.bounds, to: rep)
    try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: path))
}

let app = NSApplication.shared
let args = CommandLine.arguments
if let i = args.firstIndex(of: "--icon"), i + 1 < args.count {
    // 앱 아이콘: 둥근 네모 바탕에 식빵 고양이
    let side: CGFloat = 1024
    let image = NSImage(size: NSSize(width: side, height: side))
    image.lockFocus()
    let plate = NSBezierPath(roundedRect: NSRect(x: 60, y: 60, width: side - 120, height: side - 120),
                             xRadius: 200, yRadius: 200)
    NSColor(srgbRed: 1.0, green: 0.86, blue: 0.88, alpha: 1).setFill()
    plate.fill()
    let rows = designs[2].rows, unit: CGFloat = 42
    let left = (side - CGFloat(rows[0].count) * unit) / 2, top = (side + CGFloat(rows.count) * unit) / 2
    for (y, row) in rows.enumerated() {
        for (x, ch) in row.enumerated() {
            let color: NSColor? = ch == "E" || ch == "e" ? ink : ch == "c" ? colors["p"] : colors[ch]
            guard let color else { continue }
            color.setFill()
            NSRect(x: left + CGFloat(x) * unit, y: top - CGFloat(y + 1) * unit, width: unit, height: unit).fill()
        }
    }
    image.unlockFocus()
    if let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff) {
        try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: args[i + 1]))
    }
    exit(0)
}
if let i = args.firstIndex(of: "--render"), i + 1 < args.count {
    // 창을 띄우지 않고 그림만 PNG로 저장 (모양 확인용)
    let dir = args[i + 1]
    for (n, design) in designs.enumerated() {
        let cat = CatView(frame: .zero)
        cat.design = design
        cat.px = 12
        cat.setFrameSize(cat.spriteSize)
        writePNG(cat, dir + "/cat\(n).png")
        cat.wag = true
        cat.happy = true
        cat.jump = 4
        writePNG(cat, dir + "/cat\(n)b.png")
        cat.happy = false
        cat.jump = 0
        cat.running = true
        for f in 0..<design.legs.count {
            cat.walkFrame = f + 1
            cat.jump = f == 0 ? 1 : 0
            writePNG(cat, dir + "/cat\(n)r\(f + 1).png")
        }
        cat.jump = 0
        cat.running = false
        cat.walkFrame = 0
        cat.sinkTarget = cat.hideDepth
        RunLoop.main.run(until: Date() + 1.2)
        writePNG(cat, dir + "/cat\(n)p.png")
        cat.happy = true
        writePNG(cat, dir + "/cat\(n)ph.png")
        cat.happy = false
        cat.asleep = true
        cat.snot = 3
        writePNG(cat, dir + "/cat\(n)ps.png")
        cat.standUp()
        cat.snot = 2
        writePNG(cat, dir + "/cat\(n)s2.png")
        cat.snot = 3
        writePNG(cat, dir + "/cat\(n)s3.png")
    }
    let yarn = BallView(frame: .zero)
    yarn.px = 12
    yarn.setFrameSize(yarn.neededSize)
    writePNG(yarn, dir + "/ball.png")
    for stage in 0..<bowlStages.count {
        let bowl = BowlView(frame: .zero)
        bowl.px = 12
        bowl.stage = stage
        bowl.setFrameSize(bowl.neededSize)
        writePNG(bowl, dir + "/bowl\(stage).png")
    }
    let q = QuipView(frame: .zero)
    q.showsHeart = true
    q.setFrameSize(q.neededSize)
    writePNG(q, dir + "/heart.png")
    q.showsHeart = false
    q.text = "2 to-dos left, meow"
    q.setFrameSize(q.neededSize)
    writePNG(q, dir + "/quip.png")
    let b = BubbleView(store: Store())
    b.showsNotes = false
    b.appearance = NSAppearance(named: .aqua)
    b.tailX = 110
    b.rebuild()
    writePNG(b, dir + "/bubble.png")
    let pane = NotesPane()
    b.notes = pane
    b.showsNotes = true
    b.rebuild()
    writePNG(b, dir + "/bubble-memo.png")
} else {
    // 종료 신호를 받으면 그냥 죽지 않고 저장을 마친 뒤 끝낸다
    signal(SIGTERM, SIG_IGN)
    let termination = DispatchSource.makeSignalSource(signal: SIGTERM, queue: .main)
    termination.setEventHandler {
        UserDefaults.standard.synchronize()
        NSApp.terminate(nil)
    }
    termination.resume()
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.accessory)
    app.run()
}
