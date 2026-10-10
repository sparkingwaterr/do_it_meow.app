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

// The nightcap worn while asleep. The tip droops to the right and ends in a pom-pom
let nightcap = [
    "....KKKK......",
    "...KNNNNKK....",
    "..KNNNNNNNKKK.",
    ".KNNNNNNNNKYYK",
    "KYYYYYYYYYKKK.",
]
let snotBlue = NSColor(srgbRed: 0.45, green: 0.76, blue: 1.0, alpha: 1)
let snotShine = NSColor(srgbRed: 0.86, green: 0.95, blue: 1.0, alpha: 1)

// E/e are the eyes (E is covered with the `lid` colour when blinking), c is blush that only shows when happy,
// and `wag` holds the rows that change when the tail wags
struct Design {
    let name: String
    let rows: [String]
    let wag: [Int: String]
    let eye: NSColor
    let lid: Character
    // Running frames (stretch → front paws land → gather → push off). Each frame is [row replacing the body's bottom row, leg rows below it...]
    // A slow walk shows no legs, the body just bobs; a cat with no `legs` moves that way when running too
    var legs: [[String]] = []
    var peek = 7  // Without peekRows: how many rows sink behind the window (so only the eyes and up show)
    // The sprite for hanging on a window with both paws. The last `pawOverhang` rows are the paws that drape over the edge
    var peekRows: [String] = []
    // Nose position (column, row). The sleep bubble comes out here
    var nose = (x: 5, y: 5)
    var peekNose = (x: 9, y: 5)
    // Top-left corner of the nightcap (column, row). Rows are negative because it sits above the head
    var cap = (x: 0, y: -3)
    var peekCap = (x: 3, y: -3)
}
let pawOverhang = 2

// All three cats share the loaf body and differ only in markings. They share the running legs too
// Short, stubby paws that spread and gather as the cat scurries
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
        ".....KK.....KK....",
        "....KBPK...KPBK...",
        "....KBBBKKKBBBK...",
        "....KBBBBWBBBBK...",
        "....KBBEBWBEBBK...",
        "....KWceWPWecWK...",
        "...KKKKWWWWWKKKK..",
        "...KWWK.....KWWK..",
        "....KK.......KK...",
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
        ".....KK.....KK....",
        "....KBPK...KPBK...",
        "....KBBBKKKBBBK...",
        "....KWWWBBBWWWK...",
        "....KWWEWBWEWWK...",
        "....KWceWPWecWK...",
        "...KKKKWWWWWKKKK..",
        "...KWWK.....KWWK..",
        "....KK.......KK...",
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
        ".....KK.....KK....",
        "....KBBK...KWWK...",
        "....KBBBKKKWWWK...",
        "....KBWWWWWWWWK...",
        "....KWWEWWWEWWK...",
        "....KWceWPWecWK...",
        "...KKKKWWWWWKKKK..",
        "...KWWK.....KWWK..",
        "....KK.......KK...",
    ]),
]

let sizes: [(name: String, px: CGFloat)] = [("Small", 3), ("Medium", 4), ("Large", 5)]

final class CatView: NSView {
    var design = designs[0] { didSet { needsDisplay = true } }
    var px: CGFloat = 3 { didSet { needsDisplay = true } }
    var blink = false { didSet { needsDisplay = true } }
    var wag = false { didSet { needsDisplay = true } }
    var jump = 0 { didSet { needsDisplay = true } }  // Height off the floor, in sprite pixels
    var happy = false { didSet { needsDisplay = true } }

    static let headroom = 6  // Empty rows kept above the cat as room to jump
    var spriteSize: NSSize {
        NSSize(width: CGFloat(design.rows[0].count) * px,
               height: CGFloat(design.rows.count + Self.headroom) * px)
    }
    var bodyRect: NSRect {
        NSRect(x: 0, y: CGFloat(Self.headroom) * px, width: bounds.width, height: CGFloat(design.rows.count) * px)
    }

    var walkFrame = 0 { didSet { needsDisplay = true } }  // 0 = not walking, 1 and up = walking frames
    var running = false { didSet { needsDisplay = true } }  // true shows legs and runs
    var dip = 0 { didSet { needsDisplay = true } }  // Rows the body ducks while eating
    var asleep = false { didSet { needsDisplay = true } }
    var isPreview = false  // A display-only cat (the preview in the app window). It ignores the mouse

    override func hitTest(_ point: NSPoint) -> NSView? { isPreview ? nil : super.hitTest(point) }

    // Copy another cat's current pose exactly
    func mirror(_ other: CatView) {
        design = other.design
        blink = other.blink
        wag = other.wag
        happy = other.happy
        asleep = other.asleep
        snot = other.snot
        walkFrame = other.walkFrame
        running = other.running
        facingRight = other.facingRight
        jump = other.jump
        dip = other.dip
        sink = other.sink
    }

    var snot = 0 { didSet { needsDisplay = true } }  // Nose bubble size, 0 to 3

    // Rows sunk below the floor line. The sunk part is not drawn, so the cat looks hidden behind the window.
    // With peekRows, once the body has sunk completely (sink > row count) the head rises again and the paws hook over the edge
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
    var facingRight = false { didSet { needsDisplay = true } }  // The sprite faces left; true flips it
    var isBusy: Bool { (hovering && mouseOver) || pressed || timer != nil }

    // When the cat walks out from under the mouse no mouseExited arrives, so check the real position
    var mouseOver: Bool {
        guard let window else { return false }
        return bodyRect.contains(convert(window.convertPoint(fromScreen: NSEvent.mouseLocation), from: nil))
    }

    private(set) var pressed = false
    var hovering = false
    var jumpFrames: [Int] = []
    var tick = 0
    var timer: Timer?

    // No jumping in place. Just hold the happy face for as many frames as were passed in
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
        if isPreview { return }
        addTrackingArea(NSTrackingArea(rect: bodyRect, options: [.mouseEnteredAndExited, .mouseMoved, .activeAlways],
                                       owner: self, userInfo: nil))
    }

    override func mouseEntered(with event: NSEvent) {
        if asleep { return }  // Hovering does nothing while asleep. It takes a click to wake
        hovering = true
        hop([1, 2, 3, 3, 2, 1, 0])
    }

    override func mouseExited(with event: NSEvent) {
        hovering = false
        petAmount = 0
    }

    // Rubbing the mouse over the body without pressing a button counts as petting
    override func mouseMoved(with event: NSEvent) {
        guard !asleep, !pressed else { return }
        petAmount += hypot(event.deltaX, event.deltaY)
        if petAmount > 90 {
            petAmount = 0
            onPet?()
        }
    }
    var onClick: ((Int) -> Void)?  // Number of clicks in a row
    var onPet: (() -> Void)?       // When petted with the mouse
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
        // Behind the near legs, overlay the far legs half a beat out of step in grey, for depth
        let legs: [String]? = {
            guard running, walkFrame > 0, !design.legs.isEmpty else { return nil }
            let n = design.legs.count
            let near = design.legs[walkFrame - 1], far = design.legs[(walkFrame - 1 + n / 2) % n]
            return zip(near, far).enumerated().map { i, pair in
                String(zip(pair.0, pair.1).map { a, b -> Character in
                    let shade: Character = b == "W" ? "S" : b
                    if i == 0 { return a == "W" || shade != "S" ? a : shade }  // Body's bottom row: open it only where a leg attaches
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

        // The nose bubble hanging down-left from the nose. rowOffset is the row where sprite row 0 is drawn
        func drawSnot(_ nose: (x: Int, y: Int), _ rowOffset: Int) {
            guard asleep, snot > 0 else { return }
            let n = [0, 1, 2, 4][min(snot, 3)]  // Cells per side
            for dy in 0..<n {
                for dx in 0..<n {
                    if n == 4 && (dx == 0 || dx == 3) && (dy == 0 || dy == 3) { continue }  // Trim the corners to make it round
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
            // The bottom `pawOverhang` rows are below the window edge. The head rises from behind the edge and the paws hook on once it is fully up
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
        // A click often wobbles a few points, more so on a small target at the screen edge. Only a clear pull
        // counts as a drag; anything less stays a click
        if !dragged && hypot(dx, dy) < 8 { return }
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

// Mode for taking the README screenshots: sample to-dos and notes replace the real ones, and nothing is saved
let demoMode = ProcessInfo.processInfo.environment["PIXELCAT_SCREENSHOTS"] != nil
    || ProcessInfo.processInfo.environment["PIXELCAT_DEMO"] != nil

// Versions before 2.1 saved everything under the bundle identifier "local.pixelcat". Copy that over once,
// leaving the old data where it is
func migrateLegacyDefaults() {
    let d = UserDefaults.standard, legacy = "local.pixelcat"
    guard Bundle.main.bundleIdentifier != legacy, !d.bool(forKey: "migratedLegacyDefaults"),
          let old = d.persistentDomain(forName: legacy), !old.isEmpty else { return }
    for (key, value) in old where d.object(forKey: key) == nil { d.set(value, forKey: key) }
    d.set(true, forKey: "migratedLegacyDefaults")
    d.synchronize()
    log("copied \(old.count) saved values from \(legacy)")
}

// MARK: - Todos

struct Todo: Codable {
    var text: String
    var done: Bool
    var due: Date?        // Reminder time
    var today: Bool?      // Marked as a to-do for today
    var notified: Bool?   // Whether the reminder has already fired

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
        if demoMode {
            let cal = Calendar.current, today = cal.startOfDay(for: Date())
            todos = [
                Todo(text: "Reply to Mina's email", done: true),
                Todo(text: "Morning stretch", done: true, today: true),
                Todo(text: "Finish the slide deck", done: false, due: Date().addingTimeInterval(2 * 3600), today: true),
                Todo(text: "Buy cat food", done: false, due: cal.date(byAdding: .hour, value: 33, to: today)),
                Todo(text: "Call the dentist", done: false),
                Todo(text: "Water the plants", done: true, today: true),
                Todo(text: "Book train tickets", done: false, due: cal.date(byAdding: .hour, value: 4 * 24 + 18, to: today)),
            ]
        } else if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode([Todo].self, from: data) {
            todos = saved
        } else {
            todos = [
                Todo(text: "Click the cat to see to-dos", done: true),
                Todo(text: "Type a new to-do below", done: false),
                Todo(text: "Click an item to check it off", done: false),
            ]
        }
    }

    func save() {
        if demoMode { return }
        if let data = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(data, forKey: key)
            UserDefaults.standard.synchronize()  // Write to disk right away so nothing is lost if the app dies
        }
    }
}

// MARK: - Bubble

let ringPink = NSColor(srgbRed: 0.96, green: 0.50, blue: 0.62, alpha: 1)
let ringGreen = NSColor(srgbRed: 0.36, green: 0.78, blue: 0.52, alpha: 1)

// Completion ring. Over a grey track, colour in the finished share clockwise from the top
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

// A progress ring with large and small text in the middle
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

// A border with one-pixel notched corners plus a stepped tail (flipped coordinates)
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

// The small speech bubble for the cat's remarks
final class QuipView: NSView {
    static let font = NSFont.systemFont(ofSize: 12, weight: .heavy)
    static let heart = [".PP.PP.", "PPPPPPP", "PPPPPPP", ".PPPPP.", "..PPP..", "...P..."]
    static let heartPx: CGFloat = 2
    var text = "" { didSet { needsDisplay = true } }
    var showsHeart = false { didSet { needsDisplay = true } }  // A pink heart instead of text
    var tailOnTop = false { didSet { needsDisplay = true } }   // The bubble sits below the cat, tail pointing up
    var tailX: CGFloat? { didSet { needsDisplay = true } }     // Where the tail starts; centred when nil

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
        let top = tailOnTop ? BubbleView.tailH : 0
        let body = NSRect(x: 0, y: top, width: bounds.width, height: bounds.height - BubbleView.tailH)
        drawPixelBubble(body: body, tailX: tailX ?? bounds.width / 2 - BubbleView.u * 2, tailOnTop: tailOnTop)
        if showsHeart {
            colors["P"]?.setFill()
            for (y, row) in Self.heart.enumerated() {
                for (x, ch) in row.enumerated() where ch == "P" {
                    NSRect(x: 9 + CGFloat(x) * Self.heartPx, y: top + 7 + CGFloat(y) * Self.heartPx,
                           width: Self.heartPx, height: Self.heartPx).fill()
                }
            }
            return
        }
        (text as NSString).draw(at: NSPoint(x: 11, y: top + 5), withAttributes: [.font: Self.font, .foregroundColor: ink])
    }
}

final class RowView: NSView {
    let done: Bool
    let deleteButton: NSButton
    var onToggle: (() -> Void)?
    var onDelete: (() -> Void)?
    var onEdit: ((String) -> Void)?  // The text was changed in place
    private let original: String

    override var isFlipped: Bool { true }

    init(frame: NSRect, todo: Todo) {
        done = todo.done
        original = todo.text
        deleteButton = NSButton(title: "×", target: nil, action: nil)
        super.init(frame: frame)

        var attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13, weight: .medium),
            .foregroundColor: todo.done ? NSColor(white: 0.62, alpha: 1) : ink,
        ]
        if todo.done { attrs[.strikethroughStyle] = NSUnderlineStyle.single.rawValue }
        // The text is edited in place: click it, type, press Return. The checkbox on the left ticks the item off
        let field = NSTextField(string: todo.text)
        field.attributedStringValue = NSAttributedString(string: todo.text, attributes: attrs)
        field.isBordered = false
        field.drawsBackground = false
        field.focusRingType = .none
        field.lineBreakMode = .byTruncatingTail
        field.cell?.usesSingleLineMode = true
        field.target = self
        field.action = #selector(textEdited(_:))
        field.frame = NSRect(x: 22, y: 2, width: frame.width - 22 - 20, height: 18)
        addSubview(field)

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
        return convert(point, from: superview).x < 20 ? self : hit  // Left of the text is the checkbox
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

    // Finish any edit in progress first, so its text is saved before the list is rebuilt
    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(nil)
        onToggle?()
    }

    @objc func deleteClicked() {
        window?.makeFirstResponder(nil)
        onDelete?()
    }

    @objc func textEdited(_ sender: NSTextField) {
        let text = sender.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if text != original { onEdit?(text) }
    }
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

    // The tabs at the top switch between to-dos and memos
    var showsNotes = UserDefaults.standard.bool(forKey: "bubbleNotes")
    var noteIndex = 0
    private var shownNote: UUID?
    private let todoTab = NSButton(title: "", target: nil, action: nil)
    private let memoTab = NSButton(title: "", target: nil, action: nil)
    private let prevNote = NSButton(title: "‹", target: nil, action: nil)
    private let nextNote = NSButton(title: "›", target: nil, action: nil)
    private let addNote = NSButton(title: "+", target: nil, action: nil)
    private let deleteNote = NSButton(title: "×", target: nil, action: nil)
    private var confirmDeleteUntil = Date.distantPast  // Pressing × again before this time deletes the memo
    private let noteScroll = NSTextView.scrollableTextView()
    private var noteText: NSTextView { noteScroll.documentView as! NSTextView }
    private var rebuilding = false
    private var dynamic: [NSView] = []  // Views rebuilt on every redraw (the heading and the to-do rows)

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
        rebuilding = true
        defer { rebuilding = false }
        dynamic.forEach { $0.removeFromSuperview() }
        dynamic = []
        setFrameSize(neededSize)
        let inner = Self.width - Self.pad * 2

        // Tabs: the selected one is dark, the other faded
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
            // Never overwrite text while the user is typing. Only replace it when moving to a different memo
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
                    guard let self, self.store.todos.indices.contains(i) else { return }
                    self.store.todos[i].done.toggle()
                    self.onChange?()
                }
                row.onDelete = { [weak self] in
                    guard let self, self.store.todos.indices.contains(i) else { return }
                    self.store.todos.remove(at: i)
                    self.onChange?()
                }
                row.onEdit = { [weak self] text in
                    // Ignore edits that surface while the rows are being torn down and rebuilt
                    guard let self, !self.rebuilding, self.store.todos.indices.contains(i) else { return }
                    if text.isEmpty {
                        self.store.todos.remove(at: i)  // Clearing the text deletes the item
                    } else {
                        self.store.todos[i].text = text
                    }
                    self.onChange?()
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

    // It takes two presses to delete, to avoid accidents
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

        // A thick line under the selected tab, and a dotted line under the whole tab row
        let active = showsNotes ? memoTab : todoTab
        ink.setFill()
        NSRect(x: active.frame.minX + 6, y: active.frame.maxY + 1, width: active.frame.width - 12, height: 3).fill()
        NSColor(white: 0.8, alpha: 1).setFill()
        var x = Self.pad
        while x < bounds.width - Self.pad {
            NSRect(x: x, y: active.frame.maxY + 5, width: 3, height: 1.5).fill()
            if !showsNotes { NSRect(x: x, y: field.frame.minY - 4, width: 3, height: 1.5).fill() }  // Above the input field
            x += 6
        }

        // A small completion ring to the right of the heading
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

// A small thing that can be picked up and moved by hand (the food bowl, the yarn ball)
class ItemView: NSView {
    var px: CGFloat = 3 { didSet { needsDisplay = true } }
    var rows: [String] { [] }
    var neededSize: NSSize { NSSize(width: CGFloat(rows[0].count) * px, height: CGFloat(rows.count) * px) }

    var onGrab: (() -> Void)?
    var onDrop: ((NSPoint) -> Void)?  // Velocity at the moment of release (points per second)

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

// Food bowl. The stage rises as it is eaten; the last stage is an empty bowl
let bowlStages = [
    ["...FFFF...", "..FFFFFF..", "KKKKKKKKKK", ".KDDDDDDK.", "..KKKKKK.."],
    ["..........", "..FFFFFF..", "KKKKKKKKKK", ".KDDDDDDK.", "..KKKKKK.."],
    ["..........", "..........", "KKKKKKKKKK", ".KDDDDDDK.", "..KKKKKK.."],
]

final class BowlView: ItemView {
    var stage = 0 { didSet { needsDisplay = true } }
    override var rows: [String] { bowlStages[min(stage, bowlStages.count - 1)] }
}

// Yarn ball. Two frames alternate as it rolls
let ballFrames = [
    ["..KKKK..", ".KRrRRK.", "KRRrRRrK", "KrRRrRRK", "KRrRRrRK", "KRRrRRrK", ".KRRrRK.", "..KKKK.."],
    ["..KKKK..", ".KRRrRK.", "KrRRrRRK", "KRrRRrRK", "KRRrRRrK", "KrRRrRRK", ".KRrRRK.", "..KKKK.."],
]

final class BallView: ItemView {
    var frameIndex = 0 { didSet { needsDisplay = true } }
    override var rows: [String] { ballFrames[frameIndex % ballFrames.count] }
}

// MARK: - Other apps' windows

// An ordinary window of another app. `frame` is in Cocoa coordinates (origin at the bottom left)
struct Win {
    let id: CGWindowID
    let frame: NSRect
}

// Front to back. Only window positions are read, never their contents or titles
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

// The horizontal range hidden by the notch (camera housing) at the top centre of a MacBook screen.
// Only returns a value when something `height` tall with its floor at `y` reaches up into the menu bar
func notchRange(atY y: CGFloat, height: CGFloat) -> ClosedRange<CGFloat>? {
    for screen in NSScreen.screens where screen.safeAreaInsets.top > 0 {
        guard let left = screen.auxiliaryTopLeftArea, let right = screen.auxiliaryTopRightArea,
              y < screen.frame.maxY, y + height > screen.frame.maxY - screen.safeAreaInsets.top else { continue }
        let width = screen.frame.width - left.width - right.width
        guard width > 0 else { continue }
        let margin: CGFloat = 8  // Keep a little clear of the notch's edge
        return (screen.frame.midX - width / 2 - margin)...(screen.frame.midX + width / 2 + margin)
    }
    return nil
}

// The window the cat is sitting on
struct Perch {
    let id: CGWindowID
    var bounds: NSRect
    var offsetX: CGFloat  // Distance from the window's left edge to the cat
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
    var quipStickyUntil = Date.distantPast
    var quipsOn = false  // The small bubbles where the cat talks to itself
    // Out-of-the-way mode: the cat lives on top of windows only, and reminders appear as a speech bubble
    // where it is instead of sending it running to the cursor
    var stayOnWindows = false

    var wanderOn = true
    var motion: Timer?   // Exists only while a walk or jump is in progress
    var perch: Perch?    // nil means on the floor
    var homeY: CGFloat = 0  // Floor height (wherever the cat was dropped by hand)
    var creeping = false    // Shuffling sideways while hidden on a window
    var sitUpUntil = Date.distantPast  // Until this time, sit up instead of hiding

    var bowlPanel: NSPanel!
    var bowl: BowlView!
    var bowlHeld = false
    var eating = false
    var asleep = false
    var snoreTimer: Timer?
    var lastFollow = Date.distantPast

    // Values the app window can change
    var runSpeed: CGFloat = 3.6   // Distance covered per tick (0.05 s) when running
    var pace: Double = 9.5        // Average seconds until the next action
    var climbChance = 55          // Chance to climb a window when on the floor (%)
    var sleepChance = 12          // Chance to fall asleep when picking an action (%)
    var followChance = 30         // Chance per second to follow the mouse when it is nearby (%)
    var feedOnDone = true         // Finishing a to-do puts out food
    var hub: Hub!                 // The app window, main menu and status item
    var hunger: Double = 20       // 0 (full) to 100 (starving)
    var bowlPerchOffset: CGFloat? // For a bowl placed on a window: its distance from the window's left edge

    enum FocusPhase { case idle, focus, rest }
    var focusPhase = FocusPhase.idle
    var focusEnds: Date?                 // When it ends, if running
    var focusRemaining: TimeInterval = 0 // Time left while paused
    var focusMinutes = 25
    var breakMinutes = 5
    var seconds = 0

    var ballPanel: NSPanel!
    var ball: BallView!
    var ballTimer: Timer?
    var ballV = NSPoint.zero  // Distance moved per tick
    var ballHeld = false
    var playing = false
    var ballToken = 0

    var hasFood: Bool { bowlPanel.isVisible && !bowlHeld && bowl.stage < bowlStages.count - 1 }

    var bodyHeight: CGFloat { CGFloat(catView.design.rows.count) * catView.px }
    // While the paws hook over the edge, lower the panel by that much so they hang below it
    var peekDrop: CGFloat { catView.inPeek ? CGFloat(pawOverhang) * catView.px : 0 }
    var idle: Bool {
        motion == nil && !asleep && !playing && !away && !ringing && !catView.isBusy && !bubblePanel.isVisible
    }

    // Away from the floor line, somewhere on screen, because of ball play or a reminder. The current spot must not be saved as the floor
    var away = false
    var ringing = false
    var jumping = false
    let updater = Updater()
    var ringTimer: Timer?
    var ringToken = 0
    var awayUntil = Date.distantPast  // Stay away until this time (still talking)

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
            if self.ringing {  // While ringing, a click silences it
                self.stopRinging()
            } else if self.asleep {
                if clicks >= 2 { self.wake() }  // A sleeping cat needs a double-click to wake
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
        stayOnWindows = d.bool(forKey: "stayOnWindows")
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
            // The cat gets hungry even while the app is closed
            let away = Date().timeIntervalSince1970 - d.double(forKey: "hungerAt")
            hunger = min(100, d.double(forKey: "hunger") + max(0, away) / 360)
        }
        if d.object(forKey: "focusMinutes") != nil { focusMinutes = max(1, d.integer(forKey: "focusMinutes")) }
        if d.object(forKey: "breakMinutes") != nil { breakMinutes = max(1, d.integer(forKey: "breakMinutes")) }
        if demoMode { hunger = 22 }
        hub = Hub(app: self)
        updater.start()
        bubble.notes = hub.notesPane
        hub.notesPane.onChange = { [weak self] in
            guard let self, self.bubblePanel.isVisible, self.bubble.showsNotes else { return }
            self.layoutBubble()
        }
        hub.install()

        // `make screenshots` runs the app with this set: capture every screen, then quit
        if let dir = ProcessInfo.processInfo.environment["PIXELCAT_SCREENSHOTS"] {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.hub.snapshotAll(to: dir) { exit(0) }
            }
        }
    }

    func configure(_ panel: NSPanel) {
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        // Above the menu bar, so the cat can also sit on top of a full-screen-height window (in the menu bar area)
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

    // `force` shows it even when chatter is off (for things that must be said, like a reminder)
    // `keepPose` leaves a cat that is hanging on a window where it is instead of making it sit up to talk
    func say(_ text: String, force: Bool = false, seconds: Double = 2.4, keepPose: Bool = false) {
        guard quipsOn || force, Date() >= quipStickyUntil || keepPose else { return }
        if bubblePanel.isVisible {
            guard force else { return }
            bubblePanel.orderOut(nil)
        }
        if !keepPose { sitUpUntil = max(sitUpUntil, Date() + seconds + 0.2) }
        quip.showsHeart = false
        quip.text = text
        showQuip(for: seconds)
    }

    // The heart shown when petted. It appears even when chatter is off
    func showHeart() {
        guard !asleep, !bubblePanel.isVisible, Date() >= quipStickyUntil else { return }
        quip.showsHeart = true
        showQuip(for: 1.6)
    }

    func showQuip(for seconds: Double) {
        positionQuip()
        quipPanel.orderFrontRegardless()
        quipToken += 1
        let token = quipToken
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
            if self?.quipToken == token { self?.hideQuip(force: true) }
        }
    }

    func positionQuip() {
        let size = quip.neededSize
        let cat = catPanel.frame
        let screen = (NSScreen.screens.first { $0.frame.contains(NSPoint(x: cat.midX, y: cat.minY + 1)) }
            ?? NSScreen.main)?.frame ?? cat
        // Above the cat when there is room; otherwise (at the top of the screen) below it with the tail pointing up
        var y = cat.minY + bodyHeight + 3
        quip.tailOnTop = y + size.height > screen.maxY
        if quip.tailOnTop { y = cat.minY - size.height - 3 }
        let x = min(max(cat.midX - size.width / 2, screen.minX + 4), max(screen.minX + 4, screen.maxX - size.width - 4))
        quip.tailX = min(max(cat.midX - x - BubbleView.u * 2, 8), size.width - 20)
        quipPanel.setFrame(NSRect(x: x, y: y, width: size.width, height: size.height), display: true)
    }

    // An announcement made in place stays up until it is dismissed; it is moved along with the cat instead of hidden
    func hideQuip(force: Bool = false) {
        if !force && Date() < quipStickyUntil { return }
        quipStickyUntil = .distantPast
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
        if demoMode { return }
        homeY = catPanel.frame.minY
        UserDefaults.standard.set(Double(catPanel.frame.minX), forKey: "catX")
        UserDefaults.standard.set(Double(homeY), forKey: "catY")
    }

    // Wherever the cat is dropped by hand becomes the new floor
    func catDragged() {
        away = false  // Where it was dropped is the new floor
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
        if quipPanel.isVisible && Date() < quipStickyUntil { positionQuip() }
        if bubblePanel.isVisible { layoutBubble() }
    }

    // Follow the window being sat on when it moves, and come down to the floor if it disappears or gets covered
    func follow() {
        guard let p = perch else {
            catView.sinkTarget = 0
            return
        }
        // While the mouse button is down, hold still: the cat must not slip out from under a click.
        // If the press turns into a drag, catDragged takes over
        if catView.pressed { return }
        // On a window the default is to peek. The cat only rises when talking, eating or running.
        // Clicking it opens the bubble while it keeps hanging
        let hiding = (motion == nil || creeping) && !hasFood && Date() > sitUpUntil
        catView.sinkTarget = hiding ? catView.hideDepth : 0
        let wins = visibleWindows()
        guard let i = wins.firstIndex(where: { $0.id == p.id }) else {
            log("perch window gone")
            leavePerch()
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
        // If the window moves the cat under the notch, step aside to the nearer side
        if let notch = notchRange(atY: f.maxY, height: bodyHeight), x + catW > notch.lowerBound, x < notch.upperBound {
            let goLeft = x + catW / 2 < (notch.lowerBound + notch.upperBound) / 2
            x = goLeft ? notch.lowerBound - catW : notch.upperBound
            perch?.offsetX = x - f.minX
        }
        let foot = NSPoint(x: x + catW / 2, y: f.maxY - 2)
        let onScreen = NSScreen.screens.contains { $0.frame.contains(NSPoint(x: foot.x, y: f.maxY + bodyHeight - 1)) }
        if !onScreen || wins[..<i].contains(where: { $0.frame.contains(foot) }) {
            log("perch covered or off screen")
            leavePerch()
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

    // Running cycles through the leg frames in order; walking bobs on two beats
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
        jumping = false
        if eating {
            eating = false
            catView.happy = false
        }
    }

    // With `run` the legs come out and it moves fast; otherwise it shuffles along slowly in loaf pose
    func walk(to targetX: CGFloat, run: Bool = false, then done: (() -> Void)? = nil) {
        cancelMotion()
        wake()
        hideQuip()
        let speed: CGFloat = run ? runSpeed : 1.2
        catView.running = run
        creeping = !run && perch != nil
        catView.facingRight = targetX > catPanel.frame.minX
        var x = catPanel.frame.minX  // Window coordinates get rounded, so the position is accumulated separately
        var tick = 0
        let t = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self else { return }
            var o = self.catPanel.frame.origin
            if abs(o.x - x) > 3 {  // If something else moved the cat, stop instead of walking on the spot
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
            if run { self.catView.jump = frame == 1 ? 1 : 0 }  // Slightly airborne on the stretch frame
            if tick % 8 == 0 { self.catView.wag.toggle() }
        }
        RunLoop.main.add(t, forMode: .common)
        motion = t
    }

    // Move in an arc. With `landing` the cat sits on that window, otherwise it lands on the floor
    func jump(to target: NSPoint, landing: Perch? = nil, then done: (() -> Void)? = nil) {
        cancelMotion()
        wake()
        hideQuip()
        perch = nil
        var start = catPanel.frame.origin
        start.y += peekDrop
        catView.standUp()
        let dist = hypot(target.x - start.x, target.y - start.y)
        // Scale the time with distance (about 2.5× running speed) so long jumps do not look like teleporting
        let frames = max(18, min(120, Int(dist / (runSpeed * 2.5))))
        let peak = min(140, 30 + dist * 0.12)
        catView.facingRight = target.x > start.x
        catView.running = true
        catView.walkFrame = 1
        jumping = true
        var n = 0
        let t = Timer(timeInterval: 0.03, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.catView.pressed {  // Grabbed in mid-air
                self.cancelMotion()
                self.away = true
                return
            }
            n += 1
            self.catView.walkFrame = self.stepFrame(n, run: true)  // Keep the paws going in the air
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

    // The window being sat on is no longer usable. In stay-on-windows mode move to another window if there is one
    func leavePerch() {
        if stayOnWindows && hopOntoWindow(frontOnly: false) { return }
        dropToFloor()
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

    // Pick a spot on the top edge of wins[i] that no other window covers
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
            if let notch = notch, x + catW > notch.lowerBound, x < notch.upperBound { continue }  // Stay out from under the notch
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
        let run = allowRun && Int.random(in: 0..<4) == 0  // Sometimes it gets the zoomies
        let distance = (run ? CGFloat.random(in: 250...600) : CGFloat.random(in: 60...220)) * (Bool.random() ? 1 : -1)
        var target = start + distance
        if !range.contains(target) { target = start - distance }
        walk(to: min(max(target, range.lowerBound), range.upperBound), run: run)
    }

    // Dash towards the mouse
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

    // Put the bowl on the cat's own line, a little way off. Once placed it can be dragged by hand
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

    // Walk to the bowl (run if it is far). To avoid jumping, the bowl is moved onto the line the cat stands on
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
        bowlPerchOffset = perch.map { b.minX - $0.bounds.minX }  // If on a window, remember the offset so the bowl follows the window

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
            self.catView.dip = tick % 2  // Nodding while eating
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
        let angle = CGFloat.random(in: 0.25...0.75) * .pi  // A little toss upwards
        throwBall(velocity: NSPoint(x: cos(angle) * 400, y: sin(angle) * 400))
    }

    // The ball was dropped or thrown. Start playing if not already
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

    // The ball rolls freely around the screen and bounces off the edges. The cat chases it anywhere and bats it away,
    // and once it has had enough it goes back to the height it came from
    func startPlay() {
        // Ball play ranges over the whole screen, so it switches stay-on-windows mode off
        if stayOnWindows {
            stayOnWindows = false
            UserDefaults.standard.set(false, forKey: "stayOnWindows")
            hub.refresh()
        }
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
            if tick > 6000 {  // Give up after three minutes
                rest()
                self.stopPlay()
                return
            }
            // While the cat is held or the to-do bubble is open, only the ball moves. It also waits while the ball is held
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
                // Bat it away from the cat, a little off to one side
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
        // Leave the ball for a moment. Pick it up and throw it again and play resumes
        ballToken += 1
        let token = ballToken
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) { [weak self] in
            guard let self, self.ballToken == token, !self.playing, !self.ballHeld else { return }
            self.ballPanel.orderOut(nil)
        }
        // Run back from wherever play ended to the original floor height
        DispatchQueue.main.asyncAfter(deadline: .now() + (caught ? 1.2 : 0)) { [weak self] in
            guard let self, !self.playing, self.motion == nil, !self.catView.pressed else { return }
            self.runHome()
        }
    }

    // Bring a cat that is floating mid-screen straight back to its floor line by running (no jump)
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
        let sizes = [0, 1, 2, 3, 3, 2, 1, 0]  // The nose bubble swells and shrinks with each breath
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

    // When the mouse comes near, sometimes trail after it: run if far, walk if close, and shuffle along while hanging if on a window
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
            if left < 8 {  // Arrived: sit and wait
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
        guard wanderOn, !stayOnWindows, idle, perch == nil, !hasFood, Date() > lastFollow + 8 else { return }
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
        if hasFood && !away {  // If there is food, drop everything and go eat
            goEat()
            return
        }
        if playing { return }
        if away {  // If somehow left in mid-air, go back home
            if motion == nil && !catView.pressed && !bubblePanel.isVisible && Date() > awayUntil { runHome() }
            return
        }
        if asleep {  // Once asleep, sleep for a minute or two on average. During focus time, sleep until it ends
            if !focusing && Int.random(in: 0..<100) < 10 { wake() }
            return
        }
        guard wanderOn, idle else { return }
        if focusing {
            fallAsleep()
            return
        }
        if hunger >= 75 && Int.random(in: 0..<100) < 35 {  // When hungry, ask for food instead of wandering
            say("I'm hungry…", force: true, seconds: 3)
            return
        }
        let roll = Int.random(in: 0..<100)
        if stayOnWindows {
            // Get onto a window and stay there: no strolling, chasing or coming down. With no window to sit on, wait
            if perch == nil {
                hopOntoWindow(frontOnly: false)
            } else if Int.random(in: 0..<100) < sleepChance / 2 {
                fallAsleep()
            } else if roll >= 92 {
                hopOntoWindow(frontOnly: false)
            }
        } else if perch != nil {
            // On a window, almost always hang and peek; move only now and then
            if Int.random(in: 0..<100) < sleepChance / 2 {
                fallAsleep()
                return
            }
            switch roll {
            case ..<87: break
            case ..<90: sitUpUntil = Date() + 3  // Pop up for a quick look around
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

    // When the user switches apps, sometimes follow onto that window to butt in
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
        let stay = menu.addItem(withTitle: "Stay on Windows", action: #selector(toggleStayOnWindows), keyEquivalent: "")
        stay.target = self
        stay.state = stayOnWindows ? .on : .off
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

    // Resize the panel while keeping the middle of the cat's feet fixed
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

    // Reopening the app icon shows the app window
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
            hunger = min(100, hunger + 100.0 / 600)  // Fully hungry after ten hours
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

    @objc func toggleStayOnWindows() {
        stayOnWindows.toggle()
        UserDefaults.standard.set(stayOnWindows, forKey: "stayOnWindows")
        if stayOnWindows && perch == nil && idle { hopOntoWindow(frontOnly: false) }
        hub.refresh()
    }

    @objc func checkForUpdates() { updater.check(userInitiated: true) }

    @objc func toggleAutoUpdate() {
        updater.automatic.toggle()
        hub.refresh()
    }

    @objc func showAbout() {
        NSApp.activate(ignoringOtherApps: true)
        let link = NSMutableAttributedString(string: "github.com/\(Updater.repository)")
        link.addAttributes([.link: URL(string: "https://github.com/\(Updater.repository)")!,
                            .font: NSFont.systemFont(ofSize: 11)], range: NSRange(location: 0, length: link.length))
        NSApp.orderFrontStandardAboutPanel(options: [.credits: link])
    }

    @objc func toggleTodoBubble() {
        toggleBubble()
        hub.refresh()
    }

    // What the cat is doing right now, in a word or two
    var activity: String {
        if ringing { return "Ringing for you" }
        if eating { return "Eating" }
        if playing { return "Chasing the yarn ball" }
        if asleep { return perch != nil ? "Sleeping on a window" : "Sleeping" }
        if jumping { return "Jumping" }
        if motion != nil { return catView.running ? "Running" : "Walking" }
        if catView.inPeek { return "Peeking over a window" }
        if perch != nil { return "Sitting on a window" }
        if catView.happy { return "Enjoying the attention" }
        return "Sitting"
    }

    // MARK: To-dos

    // Called whenever the to-dos change (from the cat's bubble or the app window)
    func todosChanged(_ old: [Todo], _ new: [Todo]) {
        let was = old.filter(\.done).count, now = new.filter(\.done).count
        if new.count >= old.count && now != was {  // A count that drops because items were deleted is ignored
            var h = history
            h[dayKey(Date())] = max(0, (h[dayKey(Date())] ?? 0) + now - was)
            if !demoMode { UserDefaults.standard.set(h, forKey: "history") }
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

    // To-dos finished per day
    var history: [String: Int] {
        if demoMode {  // Sample data: the last 7 days
            let counts = [3, 5, 2, 6, 4, 7, 3]
            return Dictionary(uniqueKeysWithValues: counts.enumerated().map {
                (dayKey(Date().addingTimeInterval(TimeInterval(-86400 * (6 - $0.offset)))), $0.element)
            })
        }
        return UserDefaults.standard.dictionary(forKey: "history") as? [String: Int] ?? [:]
    }
    var doneToday: Int { history[dayKey(Date())] ?? 0 }

    // Days in a row, up to today, on which something was finished
    var streak: Int {
        let h = history
        var day = Date(), n = 0
        if (h[dayKey(day)] ?? 0) == 0 { day = day.addingTimeInterval(-86400) }  // If nothing is done yet today, count up to yesterday
        while (h[dayKey(day)] ?? 0) > 0 {
            n += 1
            day = day.addingTimeInterval(-86400)
        }
        return n
    }

    // Finishing a to-do pleases the cat, and feeds it if that is switched on
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
        if demoMode { return }
        UserDefaults.standard.set(hunger, forKey: "hunger")
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "hungerAt")
    }

    // The current mood and why. It depends on hunger, overdue to-dos and what was finished today
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

    // Find a to-do whose reminder time has come and have the cat announce it
    func checkDue() {
        let now = Date()
        for i in store.todos.indices {
            let t = store.todos[i]
            guard !t.done, t.notified != true, let due = t.due, due <= now else { continue }
            store.todos[i].notified = true
            ring("Time for: \(t.text)")
            return  // One at a time
        }
    }

    // Play a sound, wake the cat, and have it run across the screen to the mouse cursor to say something
    func comeAndSay(_ text: String, hold: Double = 9) {
        log("announce: \(text)")
        NSSound(named: "Glass")?.play()
        wake()
        if stayOnWindows {  // Say it from where the cat is, without leaving its window
            quipStickyUntil = Date() + hold
            say(text, force: true, seconds: hold, keepPose: true)
            return
        }
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

        // Stop just below the cursor, with a gap so it neither covers the cursor nor counts as hovering
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
            if dist < 4 || tick > 500 {  // Arrived, or still not caught up after 15 seconds: say it here
                self.cancelMotion()
                log("arrived at cursor")
                self.say(text, force: true, seconds: hold)
                self.awayUntil = Date() + hold + 1
                let token = self.ringToken
                DispatchQueue.main.asyncAfter(deadline: .now() + hold + 0.5) { [weak self] in
                    guard let self, self.ringToken == token, !self.ringing, self.motion == nil, !self.playing,
                          !self.catView.pressed, self.perch == nil else { return }
                    self.runHome()  // Done talking: go back home
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

    // Timers and reminders: the cat runs to the cursor and the sound repeats until the cat is clicked (one minute at most)
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
        comeAndSay(text, hold: 60)  // The first sound is played in here
        hub.refresh()
    }

    @objc func stopRinging(returnHome: Bool = true) {
        guard ringing else { return }
        log("ring stopped")
        ringing = false
        ringToken += 1
        ringTimer?.invalidate()
        ringTimer = nil
        hideQuip(force: true)
        awayUntil = .distantPast
        if returnHome && away && !playing && !catView.pressed {
            cancelMotion()
            runHome()
        }
        hub.refresh()
    }

    // MARK: Focus timer

    var focusing: Bool { focusPhase == .focus && focusEnds != nil }

    // Time left in the current phase
    var focusLeft: TimeInterval {
        if let ends = focusEnds { return max(0, ends.timeIntervalSinceNow) }
        return focusPhase == .idle ? TimeInterval(focusMinutes * 60) : focusRemaining
    }

    var focusSessionsToday: Int {
        (UserDefaults.standard.dictionary(forKey: "focusHistory") as? [String: Int])?[dayKey(Date())] ?? 0
    }

    // Start, pause and resume share one button
    @objc func toggleFocus() {
        if let ends = focusEnds {  // Running → pause
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

    // While the user focuses, the cat sleeps and stays out of the way
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
    // App icon: the loaf cat on a rounded square
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
    // Save pictures as PNG without showing any windows (for checking how things look)
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
    // On a termination signal, finish saving before quitting instead of just dying
    signal(SIGTERM, SIG_IGN)
    let termination = DispatchSource.makeSignalSource(signal: SIGTERM, queue: .main)
    termination.setEventHandler {
        UserDefaults.standard.synchronize()
        NSApp.terminate(nil)
    }
    termination.resume()
    migrateLegacyDefaults()
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.accessory)
    app.run()
}
