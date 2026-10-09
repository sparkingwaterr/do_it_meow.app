import Cocoa

// 새끼 고양이: 어미보다 작고 몸이 짧다. 어미 뒤를 졸졸 따라다니고, 어미가 하는 대로 따라 한다

let kittenDesign = Design(name: "Kitten", rows: [
    ".KK...KK.....",
    "KBBK.KWWK....",
    "KBBBKWWWKKK..",
    "KBBWWWWWWBWK.",
    "KWWEWWWEWBBWK",
    "KWceWPWecWWWK",
    "KWWWWWWWWWBBK",
    ".KKKKKKKKKKK.",
], wag: [
    6: "KWWWWWWWWBBBK",
], eye: ink, lid: "W", legs: [
    [".WWKKKKKKKWW.",
     "KWWK.....KWWK",
     ".KK.......KK."],
    [".KWWKKKKKWWK.",
     ".KWWK...KWWK.",
     "..KK.....KK.."],
    [".KKKWWKWWKKK.",
     "...KWWKWWK...",
     "....KK.KK...."],
    [".KKWWKKKWWKK.",
     "..KWWK.KWWK..",
     "...KK...KK..."],
], peekRows: [
    "..KK.....KK..",
    ".KBBK...KWWK.",
    ".KBBBKKKWWWK.",
    ".KBWWWWWWWWK.",
    ".KWEWWWWWEWK.",
    ".KceWWPWWecK.",
    "KKKKWWWWWKKKK",
    "KWWK.....KWWK",
    ".KK.......KK.",
], nose: (x: 5, y: 5), peekNose: (x: 6, y: 5), cap: (x: 0, y: -3), peekCap: (x: 0, y: -3))

final class Kitten {
    unowned let app: AppDelegate
    let panel: NSPanel
    let view = CatView(frame: .zero)
    private var pos = NSPoint.zero
    private var timer: Timer?
    private var tick = 0
    private var running = false
    private(set) var enabled = false

    init(app: AppDelegate) {
        self.app = app
        panel = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        app.configure(panel)
        panel.ignoresMouseEvents = true
        view.isPreview = true
        view.design = kittenDesign
        panel.contentView = view
    }

    // 어미보다 한 단계 작게
    private func resize() {
        view.px = max(2, app.catView.px - 1)
        view.setFrameSize(view.spriteSize)
        panel.setContentSize(view.spriteSize)
    }

    func setEnabled(_ on: Bool) {
        enabled = on
        timer?.invalidate()
        timer = nil
        guard on else {
            panel.orderOut(nil)
            return
        }
        resize()
        pos = app.catPanel.frame.origin
        panel.setFrameOrigin(pos)
        panel.orderFrontRegardless()
        let t = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in self?.step() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func step() {
        tick += 1
        let mom = app.catPanel.frame
        let momView: CatView = app.catView
        if view.px != max(2, momView.px - 1) { resize() }
        let w = panel.frame.width, gap: CGFloat = 4

        // 어미가 창에 매달리면 같이 매달리고, 자면 같이 자고, 좋아하면 같이 좋아한다
        view.sinkTarget = momView.sinkTarget > 0 ? view.hideDepth : 0
        view.asleep = app.asleep
        view.snot = app.asleep ? momView.snot : 0
        view.happy = momView.happy
        if tick % 90 == 0 { view.blink = true } else if tick % 90 == 3 { view.blink = false }

        // 어미의 발밑 줄, 어미 등 뒤가 제자리. 자리가 없으면 앞쪽에 선다
        let feetY = mom.minY + (momView.inPeek ? CGFloat(pawOverhang) * momView.px : 0)
        let behind = momView.facingRight ? mom.minX - w - gap : mom.maxX + gap
        let ahead = momView.facingRight ? mom.maxX + gap : mom.minX - w - gap
        let range: ClosedRange<CGFloat>? = {
            if let b = app.perch?.bounds { return b.maxX - w > b.minX ? b.minX...(b.maxX - w) : nil }
            guard let s = (app.catPanel.screen ?? NSScreen.main)?.visibleFrame else { return nil }
            return s.minX...(s.maxX - w)
        }()
        var tx = behind
        if let range, !range.contains(tx) { tx = range.contains(ahead) ? ahead : min(max(tx, range.lowerBound), range.upperBound) }
        let ty = feetY - (view.inPeek ? CGFloat(pawOverhang) * view.px : 0)

        let dx = tx - pos.x, dy = ty - pos.y, dist = hypot(dx, dy)
        if dist > 2.5 {
            if dist > 70 { running = true } else if dist < 20 { running = false }
            let speed: CGFloat = dist > 500 ? 14 : running ? app.runSpeed * 1.7 : 1.5
            let length = min(speed, dist)
            pos.x += dx / dist * length
            pos.y += dy / dist * length
            if abs(dx) > 3 { view.facingRight = dx > 0 }
            let frame = running ? (tick / 2) % max(view.design.legs.count, 2) + 1 : (tick / 6) % 2 + 1
            view.running = running
            view.walkFrame = frame
            view.jump = running && frame == 1 ? 1 : 0
            view.wag = false
        } else {
            pos = NSPoint(x: tx, y: ty)
            running = false
            view.running = false
            view.walkFrame = 0
            view.jump = 0
            view.facingRight = momView.facingRight
            view.wag = tick % 130 < 12 && (tick / 3) % 2 == 0  // 가끔 꼬리를 살랑
        }
        panel.setFrameOrigin(pos)
    }
}
