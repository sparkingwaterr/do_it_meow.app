import Carbon.HIToolbox
import Cocoa
import ServiceManagement

// 본 창(개요, 할 일, 집중, 고양이, 설정), 메뉴 막대, 상태 아이콘, 빠른 추가 창

// MARK: - Small views

// 옅은 바탕의 둥근 카드
final class CardView: NSView {
    init(_ content: NSView, padding: CGFloat = 14) {
        super.init(frame: .zero)
        wantsLayer = true
        layer?.cornerRadius = 10
        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    override var wantsUpdateLayer: Bool { true }
    override func updateLayer() {
        layer?.backgroundColor = NSColor.labelColor.withAlphaComponent(0.06).cgColor
    }
}

final class SideButton: NSButton {
    var selected = false { didSet { needsDisplay = true } }

    override func draw(_ dirtyRect: NSRect) {
        if selected {
            NSColor.labelColor.withAlphaComponent(0.12).setFill()
            NSBezierPath(roundedRect: bounds, xRadius: 6, yRadius: 6).fill()
        }
        super.draw(dirtyRect)
    }
}

// 지난 7일 동안 하루에 끝낸 할 일 수. 한 가지 색 막대이고, 오늘만 진하게 한다
final class BarChartView: NSView, NSViewToolTipOwner {
    struct Bar {
        let label: String
        let value: Int
        let today: Bool
        let tip: String
    }

    var bars: [Bar] = [] {
        didSet {
            needsDisplay = true
            needsLayout = true
        }
    }
    private var tipTags: [NSView.ToolTipTag] = []

    private let labelHeight: CGFloat = 18
    private let topPad: CGFloat = 18
    private var slot: CGFloat { bounds.width / CGFloat(max(bars.count, 1)) }

    override func layout() {
        super.layout()
        removeAllToolTips()
        tipTags = bars.indices.map {
            addToolTip(NSRect(x: CGFloat($0) * slot, y: 0, width: slot, height: bounds.height), owner: self, userData: nil)
        }
    }

    func view(_ view: NSView, stringForToolTip tag: NSView.ToolTipTag, point: NSPoint,
              userData data: UnsafeMutableRawPointer?) -> String {
        tipTags.firstIndex(of: tag).map { bars[$0].tip } ?? ""
    }

    override func draw(_ dirtyRect: NSRect) {
        guard !bars.isEmpty else { return }
        let plotBottom = labelHeight, plotHeight = bounds.height - labelHeight - topPad
        let top = max(bars.map(\.value).max() ?? 0, 1)
        let barWidth = min(26, slot - 10)

        NSColor.separatorColor.setFill()
        NSRect(x: 0, y: plotBottom - 1, width: bounds.width, height: 1).fill()

        for (i, bar) in bars.enumerated() {
            let x = CGFloat(i) * slot + (slot - barWidth) / 2
            let h = bar.value == 0 ? 2 : max(5, plotHeight * CGFloat(bar.value) / CGFloat(top))
            let r = min(4, h / 2)
            let path = NSBezierPath()  // 윗모서리만 둥글게, 바닥은 기준선에 붙인다
            path.move(to: NSPoint(x: x, y: plotBottom))
            path.line(to: NSPoint(x: x, y: plotBottom + h - r))
            path.appendArc(withCenter: NSPoint(x: x + r, y: plotBottom + h - r), radius: r,
                           startAngle: 180, endAngle: 90, clockwise: true)
            path.line(to: NSPoint(x: x + barWidth - r, y: plotBottom + h))
            path.appendArc(withCenter: NSPoint(x: x + barWidth - r, y: plotBottom + h - r), radius: r,
                           startAngle: 90, endAngle: 0, clockwise: true)
            path.line(to: NSPoint(x: x + barWidth, y: plotBottom))
            path.close()
            (bar.value == 0 ? NSColor.tertiaryLabelColor
                : NSColor.controlAccentColor.withAlphaComponent(bar.today ? 1 : 0.5)).setFill()
            path.fill()

            let dayAttrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 10, weight: bar.today ? .bold : .regular),
                .foregroundColor: bar.today ? NSColor.labelColor : NSColor.secondaryLabelColor,
            ]
            let day = bar.label as NSString
            day.draw(at: NSPoint(x: x + barWidth / 2 - day.size(withAttributes: dayAttrs).width / 2, y: 2),
                     withAttributes: dayAttrs)

            // 숫자는 오늘과 가장 많이 한 날에만 붙인다
            if bar.value > 0 && (bar.today || bar.value == top) {
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .semibold),
                    .foregroundColor: NSColor.labelColor,
                ]
                let text = "\(bar.value)" as NSString
                text.draw(at: NSPoint(x: x + barWidth / 2 - text.size(withAttributes: attrs).width / 2,
                                      y: plotBottom + h + 3), withAttributes: attrs)
            }
        }
    }
}

// MARK: - Hub

final class Hub: NSObject, NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate,
    NSTextFieldDelegate {
    unowned let app: AppDelegate

    var window: NSWindow?
    var pages: [NSView] = []
    var sideButtons: [SideButton] = []
    var current = 0
    var controls: [String: NSView] = [:]

    var statusItem: NSStatusItem?
    var statusMenu = NSMenu()

    var table: NSTableView?
    var filter = 0          // 0 전체, 1 오늘, 2 남은 것
    var visible: [Int] = [] // 표의 줄 → 할 일 번호
    var addField: NSTextField?

    var popover: NSPopover?
    var duePicker: NSDatePicker?
    var dueIndex = 0

    var quickPanel: KeyPanel?
    var quickField: NSTextField?

    var loginNote = ""
    let notesPane = NotesPane()
    let timersPane = TimersPane()
    // 달력에는 마감 시간이 있는 할 일을 올린다
    lazy var calendarPane = CalendarPane { [unowned self] in
        self.app.store.todos.compactMap { t in t.due.map { CalendarItem(date: $0, title: t.text, done: t.done) } }
    }
    let english = Locale(identifier: "en_US")  // 화면 글자가 영어라서 날짜도 영어로 맞춘다

    static let pageNames = ["Overview", "To-Dos", "Notes", "Timers", "Calendar", "Focus", "Cat", "Settings"]
    static let pageIcons = ["square.grid.2x2", "checklist", "note.text", "hourglass", "calendar", "timer", "pawprint", "gearshape"]
    static let focusChoices = [15, 25, 45, 60]
    static let breakChoices = [5, 10, 15]

    init(app: AppDelegate) {
        self.app = app
    }

    func install() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusMenu.delegate = self
        item.menu = statusMenu
        statusItem = item
        timersPane.onTest = { [unowned self] in self.app.ring("Test ring") }
        timersPane.onChange = { [unowned self] in self.refresh() }
        installMainMenu()
        installHotKey()
        NotificationCenter.default.addObserver(self, selector: #selector(quickAdd),
                                               name: Notification.Name("PixelCatHotKey"), object: nil)
        updateStatusTitle()
    }

    // MARK: Window

    func show(page: Int? = nil) {
        if window == nil { build() }
        if let page { select(page) }
        NSApp.setActivationPolicy(.regular)  // 창이 떠 있는 동안은 Dock 과 메뉴 막대에 나오는 보통 앱
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
        reloadTodos()
        refresh()
    }

    func windowWillClose(_ notification: Notification) {
        guard (notification.object as? NSWindow) === window else { return }
        NSApp.setActivationPolicy(.accessory)  // 창을 닫으면 다시 고양이만 남는다
    }

    func windowDidResignKey(_ notification: Notification) {
        if (notification.object as? NSWindow) === quickPanel { quickPanel?.orderOut(nil) }
    }

    private func build() {
        let root = NSView()

        let side = NSVisualEffectView()
        side.material = .sidebar
        side.blendingMode = .behindWindow
        side.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(side)

        let nav = NSStackView()
        nav.orientation = .vertical
        nav.alignment = .leading
        nav.spacing = 4
        nav.translatesAutoresizingMaskIntoConstraints = false
        side.addSubview(nav)
        for (i, name) in Self.pageNames.enumerated() {
            let b = SideButton(title: "  " + name, target: self, action: #selector(sideClicked(_:)))
            b.isBordered = false
            b.alignment = .left
            b.font = .systemFont(ofSize: 13, weight: .medium)
            b.image = NSImage(systemSymbolName: Self.pageIcons[i], accessibilityDescription: name)
            b.imagePosition = .imageLeading
            b.tag = i
            b.widthAnchor.constraint(equalToConstant: 156).isActive = true
            b.heightAnchor.constraint(equalToConstant: 30).isActive = true
            sideButtons.append(b)
            nav.addArrangedSubview(b)
        }
        let status = label("", size: 11, color: .secondaryLabelColor)
        status.maximumNumberOfLines = 3
        status.preferredMaxLayoutWidth = 150
        status.translatesAutoresizingMaskIntoConstraints = false
        controls["side.status"] = status
        side.addSubview(status)

        let content = NSView()
        content.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(content)

        NSLayoutConstraint.activate([
            side.topAnchor.constraint(equalTo: root.topAnchor),
            side.bottomAnchor.constraint(equalTo: root.bottomAnchor),
            side.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            side.widthAnchor.constraint(equalToConstant: 180),
            nav.topAnchor.constraint(equalTo: side.topAnchor, constant: 44),
            nav.leadingAnchor.constraint(equalTo: side.leadingAnchor, constant: 12),
            status.leadingAnchor.constraint(equalTo: side.leadingAnchor, constant: 16),
            status.bottomAnchor.constraint(equalTo: side.bottomAnchor, constant: -16),
            content.topAnchor.constraint(equalTo: root.topAnchor),
            content.bottomAnchor.constraint(equalTo: root.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: side.trailingAnchor),
            content.trailingAnchor.constraint(equalTo: root.trailingAnchor),
        ])

        pages = [buildOverview(), buildTodos(), notesPane.view, timersPane.view, calendarPane.view,
                 buildFocus(), buildCat(), buildSettings()]
        for (i, page) in pages.enumerated() {
            page.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview(page)
            let stretch = (1...4).contains(i)  // 할 일, 메모, 타이머, 달력은 창 크기를 따라 늘어난다
            NSLayoutConstraint.activate([
                page.topAnchor.constraint(equalTo: content.topAnchor, constant: 40),
                page.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 28),
                stretch ? page.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -28)
                    : page.trailingAnchor.constraint(lessThanOrEqualTo: content.trailingAnchor, constant: -28),
                stretch ? page.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -24)
                    : page.bottomAnchor.constraint(lessThanOrEqualTo: content.bottomAnchor, constant: -24),
            ])
        }

        let w = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 860, height: 620),
                         styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                         backing: .buffered, defer: false)
        w.title = "Pixel Cat"
        w.titlebarAppearsTransparent = true
        w.isReleasedWhenClosed = false
        w.contentView = root
        w.setContentSize(NSSize(width: 860, height: 620))
        w.contentMinSize = NSSize(width: 820, height: 600)
        w.delegate = self
        w.center()
        window = w
        select(0)
    }

    @objc private func sideClicked(_ sender: NSButton) { select(sender.tag) }

    func select(_ index: Int) {
        current = index
        for (i, page) in pages.enumerated() { page.isHidden = i != index }
        for (i, b) in sideButtons.enumerated() { b.selected = i == index }
        refresh()
    }

    // MARK: Building blocks

    private func label(_ text: String, size: CGFloat = 13, weight: NSFont.Weight = .regular,
                       color: NSColor = .labelColor) -> NSTextField {
        let l = NSTextField(labelWithString: text)
        l.font = .systemFont(ofSize: size, weight: weight)
        l.textColor = color
        return l
    }

    private func keyed<T: NSView>(_ key: String, _ view: T) -> T {
        controls[key] = view
        return view
    }

    private func vstack(_ views: [NSView], spacing: CGFloat = 8) -> NSStackView {
        let s = NSStackView(views: views)
        s.orientation = .vertical
        s.alignment = .leading
        s.spacing = spacing
        return s
    }

    private func hstack(_ views: [NSView], spacing: CGFloat = 8) -> NSStackView {
        let s = NSStackView(views: views)
        s.spacing = spacing
        return s
    }

    private func button(_ title: String, _ action: Selector, target: AnyObject? = nil) -> NSButton {
        NSButton(title: title, target: target ?? app, action: action)
    }

    private func check(_ title: String, _ action: Selector, target: AnyObject? = nil) -> NSButton {
        NSButton(checkboxWithTitle: title, target: target ?? app, action: action)
    }

    private func heading(_ text: String) -> NSTextField { label(text, size: 26, weight: .bold) }
    private func caption(_ text: String) -> NSTextField {
        label(text.uppercased(), size: 10, weight: .semibold, color: .secondaryLabelColor)
    }

    private func fixed(_ view: NSView, width: CGFloat? = nil, height: CGFloat? = nil) -> NSView {
        if let width { view.widthAnchor.constraint(equalToConstant: width).isActive = true }
        if let height { view.heightAnchor.constraint(equalToConstant: height).isActive = true }
        return view
    }

    private func hungerBar(_ key: String) -> NSProgressIndicator {
        let bar = NSProgressIndicator()
        bar.style = .bar
        bar.isIndeterminate = false
        bar.minValue = 0
        bar.maxValue = 100
        bar.controlSize = .small
        bar.widthAnchor.constraint(equalToConstant: 130).isActive = true
        return keyed(key, bar)
    }

    // 기분, 이유, 배부른 정도
    private func moodBlock(_ prefix: String) -> NSView {
        vstack([
            caption("Cat"),
            keyed(prefix + ".mood", label("", size: 18, weight: .bold)),
            keyed(prefix + ".detail", label("", size: 12, color: .secondaryLabelColor)),
            hstack([label("Fullness", size: 11, color: .secondaryLabelColor), hungerBar(prefix + ".full")]),
        ], spacing: 6)
    }

    // MARK: Pages

    private func buildOverview() -> NSView {
        let ring = keyed("ov.ring", RingView())
        _ = fixed(ring, width: 132, height: 132)
        let progress = CardView(hstack([
            ring,
            vstack([
                keyed("ov.scope", caption("All to-dos")),
                keyed("ov.summary", label("", size: 18, weight: .bold)),
                keyed("ov.left", label("", size: 12, color: .secondaryLabelColor)),
                keyed("ov.today", label("", size: 12, color: .secondaryLabelColor)),
                keyed("ov.streak", label("", size: 12, color: .secondaryLabelColor)),
            ], spacing: 5),
        ], spacing: 18))

        let cat = CardView(vstack([
            moodBlock("ov"),
            hstack([button("Put Out Food", #selector(AppDelegate.putFood)),
                    keyed("ov.ball", button("Throw Yarn Ball", #selector(AppDelegate.toggleBall)))]),
        ], spacing: 12))

        let chart = keyed("ov.chart", BarChartView())
        _ = fixed(chart, width: 300, height: 130)
        let week = CardView(vstack([caption("Finished in the last 7 days"), chart], spacing: 10))

        let next = keyed("ov.next", label("", size: 12))
        next.maximumNumberOfLines = 4
        next.preferredMaxLayoutWidth = 230
        let upcoming = CardView(vstack([
            caption("Coming up"),
            fixed(next, width: 230),
            caption("Focus"),
            keyed("ov.focus", label("", size: 12)),
            keyed("ov.focusBtn", button("Start Focus", #selector(AppDelegate.toggleFocus))),
        ], spacing: 8))

        let top = hstack([progress, cat], spacing: 14)
        top.alignment = .top
        let bottom = hstack([week, upcoming], spacing: 14)
        bottom.alignment = .top
        return vstack([
            heading("Overview"),
            keyed("ov.date", label("", size: 13, color: .secondaryLabelColor)),
            top, bottom,
        ], spacing: 14)
    }

    private func buildTodos() -> NSView {
        let add = NSTextField()
        add.placeholderString = "Add a to-do and press Return"
        add.target = self
        add.action = #selector(addFromField(_:))
        add.cell?.sendsActionOnEndEditing = false
        add.font = .systemFont(ofSize: 14)
        add.setContentHuggingPriority(.defaultLow, for: .horizontal)
        addField = add

        let seg = NSSegmentedControl(labels: ["All", "Today", "Open"], trackingMode: .selectOne,
                                     target: self, action: #selector(filterChanged(_:)))
        seg.selectedSegment = 0
        let hint = keyed("td.hint", label("", size: 11, color: .secondaryLabelColor))
        let spacer = NSView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let filterRow = hstack([seg, spacer, hint])

        let t = NSTableView()
        t.headerView = nil
        t.rowHeight = 30
        t.selectionHighlightStyle = .none
        t.backgroundColor = .clear
        t.intercellSpacing = NSSize(width: 6, height: 4)
        for (id, width) in [("done", 24.0), ("text", 300.0), ("due", 140.0), ("today", 26.0), ("del", 24.0)] {
            let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(id))
            col.width = CGFloat(width)
            if id == "text" {
                col.resizingMask = .autoresizingMask
            } else {
                col.minWidth = CGFloat(width)
                col.maxWidth = CGFloat(width)
                col.resizingMask = []
            }
            t.addTableColumn(col)
        }
        t.columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle
        t.dataSource = self
        t.delegate = self
        t.registerForDraggedTypes([.string])
        t.setDraggingSourceOperationMask(.move, forLocal: true)
        table = t

        let scroll = NSScrollView()
        scroll.documentView = t
        scroll.hasVerticalScroller = true
        scroll.drawsBackground = false
        scroll.setContentHuggingPriority(.defaultLow, for: .vertical)
        scroll.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        let stack = vstack([
            heading("To-Dos"),
            hstack([add, button("Add", #selector(addFromButton), target: self)]),
            filterRow,
            scroll,
            hstack([keyed("td.clear", button("Clear Completed", #selector(AppDelegate.clearDone))),
                    keyed("td.bubble", button("Show on Cat", #selector(AppDelegate.toggleTodoBubble)))]),
        ], spacing: 12)
        // 입력 줄, 거르기 줄, 표는 가로로 꽉 채운다
        for v in [add.superview!, filterRow, scroll] {
            v.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        }
        return stack
    }

    private func buildFocus() -> NSView {
        let ring = keyed("fo.ring", RingView())
        ring.bigSize = 44
        _ = fixed(ring, width: 240, height: 240)
        let focusSeg = NSSegmentedControl(labels: Self.focusChoices.map { "\($0)" }, trackingMode: .selectOne,
                                          target: self, action: #selector(lengthsChanged))
        let breakSeg = NSSegmentedControl(labels: Self.breakChoices.map { "\($0)" }, trackingMode: .selectOne,
                                          target: self, action: #selector(lengthsChanged))
        let hint = label("The cat naps while you focus and comes to get you when time is up.",
                         size: 12, color: .secondaryLabelColor)
        return vstack([
            heading("Focus"),
            ring,
            hstack([keyed("fo.start", button("Start", #selector(AppDelegate.toggleFocus))),
                    button("Reset", #selector(AppDelegate.resetFocus))]),
            hstack([fixed(label("Focus minutes"), width: 100), keyed("fo.len", focusSeg)]),
            hstack([fixed(label("Break minutes"), width: 100), keyed("fo.brk", breakSeg)]),
            keyed("fo.sessions", label("", size: 12, color: .secondaryLabelColor)),
            hint,
        ], spacing: 14)
    }

    private func buildCat() -> NSView {
        let look = NSSegmentedControl(labels: designs.map(\.name), trackingMode: .selectOne,
                                      target: self, action: #selector(lookChanged(_:)))
        let size = NSSegmentedControl(labels: sizes.map(\.name), trackingMode: .selectOne,
                                      target: self, action: #selector(sizeChanged(_:)))
        return vstack([
            heading("Cat"),
            CardView(moodBlock("cp")),
            caption("Appearance"),
            hstack([fixed(label("Look"), width: 60), keyed("cp.look", look)]),
            hstack([fixed(label("Size"), width: 60), keyed("cp.size", size)]),
            caption("Play"),
            hstack([button("Put Out Food", #selector(AppDelegate.putFood)),
                    keyed("cp.ball", button("Throw Yarn Ball", #selector(AppDelegate.toggleBall))),
                    keyed("cp.sleep", button("Put to Sleep", #selector(AppDelegate.toggleSleep)))]),
            hstack([keyed("cp.climb", button("Climb a Window", #selector(AppDelegate.climbWindow))),
                    keyed("cp.down", button("Come Down", #selector(AppDelegate.comeDown))),
                    keyed("cp.bubble", button("Show To-Dos on Cat", #selector(AppDelegate.toggleTodoBubble)))]),
            label("Tip: stroke the cat with the mouse for a heart. Double-click to wake it.",
                  size: 12, color: .secondaryLabelColor),
        ], spacing: 12)
    }

    private func buildSettings() -> NSView {
        func slider(_ key: String, _ title: String, _ range: ClosedRange<Double>, _ low: String, _ high: String) -> NSView {
            let s = NSSlider(value: range.lowerBound, minValue: range.lowerBound, maxValue: range.upperBound,
                             target: self, action: #selector(sliderChanged(_:)))
            s.identifier = NSUserInterfaceItemIdentifier(key)
            s.widthAnchor.constraint(equalToConstant: 200).isActive = true
            controls["st." + key] = s
            return hstack([fixed(label(title), width: 120),
                           fixed(label(low, size: 10, color: .secondaryLabelColor), width: 34), s,
                           label(high, size: 10, color: .secondaryLabelColor)])
        }
        let note = keyed("st.loginNote", label("", size: 11, color: .secondaryLabelColor))
        note.maximumNumberOfLines = 2
        note.preferredMaxLayoutWidth = 440
        return vstack([
            heading("Settings"),
            caption("General"),
            keyed("st.login", check("Open Pixel Cat when I log in", #selector(loginChanged(_:)), target: self)),
            note,
            keyed("st.feed", check("Give the cat food when I finish a to-do", #selector(AppDelegate.toggleFeedOnDone))),
            label("Quick add from any app: Control-Option-T", size: 12, color: .secondaryLabelColor),
            caption("Behavior"),
            keyed("st.wander", check("Wander around", #selector(AppDelegate.toggleWander))),
            keyed("st.quips", check("Cat chatter", #selector(AppDelegate.toggleQuips))),
            slider("runSpeed", "Run speed", 1.5...7, "slow", "fast"),
            slider("pace", "Activity", -30...(-3), "calm", "busy"),
            slider("climbChance", "Climb windows", 0...100, "never", "often"),
            slider("sleepChance", "Sleepiness", 0...50, "never", "often"),
            slider("followChance", "Follow mouse", 0...100, "never", "often"),
            button("Quit Pixel Cat", #selector(AppDelegate.quit)),
        ], spacing: 10)
    }

    // MARK: Refresh

    // 한 초마다 불린다. 창이 안 보이면 상태 아이콘만 고친다
    func tick() {
        updateStatusTitle()
        if window?.isVisible == true {
            refresh()
            if current == 3 { timersPane.tick() }
        }
    }

    private func clock(_ t: TimeInterval) -> String {
        let s = Int(t.rounded(.up))
        return String(format: "%d:%02d", s / 60, s % 60)
    }

    private func updateStatusTitle() {
        let left = app.store.todos.filter { !$0.done }.count
        // 집중 타이머가 돌면 그 시간을, 아니면 가장 먼저 끝나는 타이머를, 그것도 없으면 남은 할 일 수를 보여 준다
        let text = app.focusEnds != nil ? clock(app.focusLeft)
            : timersPane.soonest(at: Date()).map { CountdownTimer.clock($0.left) } ?? (left > 0 ? "\(left)" : "")
        statusItem?.button?.title = app.ringing ? "🐱 ⏰" : text.isEmpty ? "🐱" : "🐱 " + text
    }

    private func dueText(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = english
        f.doesRelativeDateFormatting = true
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }

    func refresh() {
        updateStatusTitle()
        guard window != nil else { return }
        let todos = app.store.todos

        // 오늘로 골라 둔 것이 있으면 그것만으로 완료율을 낸다
        let scoped = todos.contains(where: \.isToday) ? todos.filter(\.isToday) : todos
        let total = scoped.count, done = scoped.filter(\.done).count
        if let ring = controls["ov.ring"] as? RingView {
            ring.fraction = total == 0 ? 0 : CGFloat(done) / CGFloat(total)
            ring.big = "\(Int((ring.fraction * 100).rounded()))%"
            ring.small = "\(done) / \(total)"
        }
        set("ov.scope", (todos.contains(where: \.isToday) ? "Today's to-dos" : "All to-dos").uppercased())
        set("ov.summary", total == 0 ? "Nothing to do" : done == total ? "All done!" : "\(done) of \(total) done")
        set("ov.left", total == 0 ? "Add your first to-do" : "\(total - done) left")
        set("ov.today", "Finished today: \(app.doneToday)")
        let streak = app.streak
        set("ov.streak", streak > 0 ? "Streak: \(streak) day\(streak == 1 ? "" : "s")" : "No streak yet")
        let df = DateFormatter()
        df.locale = english
        df.dateFormat = "EEEE, MMMM d"
        set("ov.date", df.string(from: Date()))

        if let chart = controls["ov.chart"] as? BarChartView {
            let history = app.history
            let wd = DateFormatter()
            wd.locale = english
            wd.dateFormat = "EEE"
            let tipDay = DateFormatter()
            tipDay.locale = english
            tipDay.dateStyle = .medium
            let bars: [BarChartView.Bar] = (0..<7).reversed().map { back in
                let day = Date().addingTimeInterval(TimeInterval(-86400 * back))
                let n = history[app.dayKey(day)] ?? 0
                return .init(label: wd.string(from: day), value: n, today: back == 0,
                             tip: "\(tipDay.string(from: day)): \(n) finished")
            }
            if chart.bars.map(\.value) != bars.map(\.value) || chart.bars.last?.label != bars.last?.label {
                chart.bars = bars
            }
        }

        let upcoming = todos.filter { !$0.done && $0.due != nil }.sorted { $0.due! < $1.due! }.prefix(3)
        var lines = upcoming.map { "\($0.due! < Date() ? "Overdue" : dueText($0.due!)) — \($0.text)" }
        if let soon = timersPane.soonest(at: Date()) {
            lines.append("Timer: \(CountdownTimer.clock(soon.left)) left\(soon.timer.label.isEmpty ? "" : " — " + soon.timer.label)")
        }
        set("ov.next", lines.isEmpty ? "No reminders or timers set." : lines.joined(separator: "\n"))

        // 고양이
        let mood = app.mood
        for p in ["ov", "cp"] {
            set(p + ".mood", mood.name)
            set(p + ".detail", mood.detail)
            (controls[p + ".full"] as? NSProgressIndicator)?.doubleValue = 100 - app.hunger
        }
        let ballTitle = app.ballPanel.isVisible ? "Put Away Yarn Ball" : "Throw Yarn Ball"
        (controls["ov.ball"] as? NSButton)?.title = ballTitle
        (controls["cp.ball"] as? NSButton)?.title = ballTitle
        (controls["cp.sleep"] as? NSButton)?.title = app.asleep ? "Wake Up" : "Put to Sleep"
        (controls["cp.climb"] as? NSButton)?.isEnabled = app.perch == nil
        (controls["cp.down"] as? NSButton)?.isEnabled = app.perch != nil
        let bubbleTitle = app.bubblePanel.isVisible ? "Hide on Cat" : "Show on Cat"
        (controls["td.bubble"] as? NSButton)?.title = bubbleTitle
        (controls["cp.bubble"] as? NSButton)?.title = app.bubblePanel.isVisible ? "Hide To-Dos on Cat" : "Show To-Dos on Cat"
        (controls["cp.look"] as? NSSegmentedControl)?.selectedSegment =
            designs.firstIndex { $0.name == app.catView.design.name } ?? 0
        (controls["cp.size"] as? NSSegmentedControl)?.selectedSegment =
            sizes.firstIndex { $0.px == app.catView.px } ?? 0
        (controls["td.clear"] as? NSButton)?.isEnabled = todos.contains(where: \.done)
        set("td.hint", filter == 0 ? "Drag to reorder · ★ marks today · ⏰ sets a reminder"
            : "Switch to All to reorder")

        // 집중
        let phase = app.focusPhase
        let running = app.focusEnds != nil
        let length = TimeInterval((phase == .rest ? app.breakMinutes : app.focusMinutes) * 60)
        if let ring = controls["fo.ring"] as? RingView {
            ring.fraction = phase == .idle ? 0 : CGFloat(1 - app.focusLeft / max(length, 1))
            ring.big = clock(app.focusLeft)
            ring.small = phase == .idle ? "Ready" : phase == .focus ? (running ? "Focus" : "Paused") : (running ? "Break" : "Break paused")
            ring.color = phase == .rest ? ringGreen : ringPink
        }
        let startTitle = running ? "Pause" : phase == .idle ? "Start Focus" : "Resume"
        (controls["fo.start"] as? NSButton)?.title = startTitle
        (controls["ov.focusBtn"] as? NSButton)?.title = startTitle
        set("ov.focus", phase == .idle ? "\(app.focusMinutes)-minute session ready"
            : "\(phase == .focus ? "Focus" : "Break"): \(clock(app.focusLeft)) left\(running ? "" : " (paused)")")
        (controls["fo.len"] as? NSSegmentedControl)?.selectedSegment = Self.focusChoices.firstIndex(of: app.focusMinutes) ?? -1
        (controls["fo.brk"] as? NSSegmentedControl)?.selectedSegment = Self.breakChoices.firstIndex(of: app.breakMinutes) ?? -1
        (controls["fo.len"] as? NSSegmentedControl)?.isEnabled = phase == .idle
        (controls["fo.brk"] as? NSSegmentedControl)?.isEnabled = phase == .idle
        let sessions = app.focusSessionsToday
        set("fo.sessions", "Sessions finished today: \(sessions)")

        // 설정
        (controls["st.wander"] as? NSButton)?.state = app.wanderOn ? .on : .off
        (controls["st.quips"] as? NSButton)?.state = app.quipsOn ? .on : .off
        (controls["st.feed"] as? NSButton)?.state = app.feedOnDone ? .on : .off
        (controls["st.login"] as? NSButton)?.state = SMAppService.mainApp.status == .enabled ? .on : .off
        set("st.loginNote", loginNote.isEmpty
            ? "Only works while the app stays where it is now, so keep it somewhere permanent."
            : loginNote)
        (controls["st.runSpeed"] as? NSSlider)?.doubleValue = Double(app.runSpeed)
        (controls["st.pace"] as? NSSlider)?.doubleValue = -app.pace  // 오른쪽으로 갈수록 자주 움직이게 뒤집어 둠
        (controls["st.climbChance"] as? NSSlider)?.doubleValue = Double(app.climbChance)
        (controls["st.sleepChance"] as? NSSlider)?.doubleValue = Double(app.sleepChance)
        (controls["st.followChance"] as? NSSlider)?.doubleValue = Double(app.followChance)

        set("side.status", "\(mood.name) cat\n\(todos.filter { !$0.done }.count) to-do\(todos.filter { !$0.done }.count == 1 ? "" : "s") left")
    }

    private func set(_ key: String, _ text: String) {
        if let l = controls[key] as? NSTextField, l.stringValue != text { l.stringValue = text }
    }

    // MARK: To-do table

    func reloadTodos() {
        let todos = app.store.todos
        visible = todos.indices.filter { filter == 0 || (filter == 1 && todos[$0].isToday) || (filter == 2 && !todos[$0].done) }
        table?.reloadData()
        if window != nil { calendarPane.reload() }
        refresh()
    }

    func numberOfRows(in tableView: NSTableView) -> Int { visible.count }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard row < visible.count, app.store.todos.indices.contains(visible[row]) else { return nil }
        let index = visible[row], todo = app.store.todos[index]
        switch tableColumn?.identifier.rawValue {
        case "done":
            let b = NSButton(checkboxWithTitle: "", target: self, action: #selector(toggleDone(_:)))
            b.state = todo.done ? .on : .off
            b.tag = index
            return b
        case "text":
            let f = NSTextField(string: todo.text)
            f.font = .systemFont(ofSize: 14)
            if todo.done {
                f.attributedStringValue = NSAttributedString(string: todo.text, attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: NSColor.secondaryLabelColor,
                    .font: NSFont.systemFont(ofSize: 14),
                ])
            }
            f.isBordered = false
            f.drawsBackground = false
            f.lineBreakMode = .byTruncatingTail
            f.cell?.usesSingleLineMode = true
            f.tag = index
            f.target = self
            f.action = #selector(editText(_:))
            // 줄 가운데에 오도록 한 겹 감싼다
            let cell = NSView()
            f.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(f)
            NSLayoutConstraint.activate([
                f.leadingAnchor.constraint(equalTo: cell.leadingAnchor),
                f.trailingAnchor.constraint(equalTo: cell.trailingAnchor),
                f.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            ])
            return cell
        case "due":
            let overdue = !todo.done && (todo.due ?? .distantFuture) < Date()
            let b = NSButton(title: todo.due.map { "⏰ " + dueText($0) } ?? "⏰", target: self, action: #selector(showDue(_:)))
            b.isBordered = false
            b.alignment = .right
            b.font = .systemFont(ofSize: 11)
            b.contentTintColor = overdue ? .systemRed : .secondaryLabelColor
            b.toolTip = todo.due == nil ? "Set a reminder" : overdue ? "Overdue. Click to change" : "Change the reminder"
            b.tag = index
            return b
        case "today":
            let b = NSButton(title: todo.isToday ? "★" : "☆", target: self, action: #selector(toggleToday(_:)))
            b.isBordered = false
            b.font = .systemFont(ofSize: 15)
            b.contentTintColor = todo.isToday ? .systemYellow : .tertiaryLabelColor
            b.toolTip = todo.isToday ? "Remove from today" : "Do this today"
            b.tag = index
            return b
        case "del":
            let b = NSButton(title: "×", target: self, action: #selector(deleteTodo(_:)))
            b.isBordered = false
            b.font = .systemFont(ofSize: 15, weight: .bold)
            b.contentTintColor = .tertiaryLabelColor
            b.toolTip = "Delete"
            b.tag = index
            return b
        default:
            return nil
        }
    }

    // 끌어서 순서 바꾸기 (전체 보기에서만)
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        filter == 0 ? "\(row)" as NSString : nil
    }

    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int,
                   proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        filter == 0 && dropOperation == .above ? .move : []
    }

    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int,
                   dropOperation: NSTableView.DropOperation) -> Bool {
        guard let text = info.draggingPasteboard.string(forType: .string), let from = Int(text),
              app.store.todos.indices.contains(from) else { return false }
        var todos = app.store.todos
        let item = todos.remove(at: from)
        todos.insert(item, at: min(from < row ? row - 1 : row, todos.count))
        app.store.todos = todos
        return true
    }

    private func addTodo(_ raw: String) {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        app.store.todos.append(Todo(text: text, done: false, due: nil, today: filter == 1 ? true : nil))
    }

    @objc private func addFromField(_ sender: NSTextField) {
        addTodo(sender.stringValue)
        sender.stringValue = ""
    }

    @objc private func addFromButton() {
        guard let field = addField else { return }
        addFromField(field)
        window?.makeFirstResponder(field)
    }

    @objc private func filterChanged(_ sender: NSSegmentedControl) {
        filter = sender.selectedSegment
        reloadTodos()
    }

    @objc private func toggleDone(_ sender: NSButton) {
        guard app.store.todos.indices.contains(sender.tag) else { return }
        app.store.todos[sender.tag].done.toggle()
    }

    @objc private func toggleToday(_ sender: NSButton) {
        guard app.store.todos.indices.contains(sender.tag) else { return }
        app.store.todos[sender.tag].today = app.store.todos[sender.tag].isToday ? nil : true
    }

    @objc private func editText(_ sender: NSTextField) {
        guard app.store.todos.indices.contains(sender.tag) else { return }
        let text = sender.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            app.store.todos.remove(at: sender.tag)  // 글자를 다 지우면 항목도 지운다
        } else if text != app.store.todos[sender.tag].text {
            app.store.todos[sender.tag].text = text
        }
    }

    @objc private func deleteTodo(_ sender: NSButton) {
        guard app.store.todos.indices.contains(sender.tag) else { return }
        app.store.todos.remove(at: sender.tag)
    }

    // MARK: Reminder popover

    @objc private func showDue(_ sender: NSButton) {
        guard app.store.todos.indices.contains(sender.tag) else { return }
        dueIndex = sender.tag
        let picker = NSDatePicker()
        picker.datePickerStyle = .textFieldAndStepper
        picker.datePickerElements = [.yearMonthDay, .hourMinute]
        picker.dateValue = app.store.todos[dueIndex].due ?? Date().addingTimeInterval(3600)
        duePicker = picker

        let content = vstack([
            label("Remind me at", size: 12, weight: .semibold),
            picker,
            hstack([button("In 1 Hour", #selector(dueInHour), target: self),
                    button("Tomorrow 9 AM", #selector(dueTomorrow), target: self)]),
            hstack([button("Clear", #selector(dueClear), target: self),
                    button("Set", #selector(dueSet), target: self)]),
        ], spacing: 10)
        content.edgeInsets = NSEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        let controller = NSViewController()
        controller.view = content
        let p = NSPopover()
        p.behavior = .transient
        p.contentViewController = controller
        p.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
        popover = p
    }

    private func setDue(_ date: Date?) {
        popover?.close()
        guard app.store.todos.indices.contains(dueIndex) else { return }
        var todo = app.store.todos[dueIndex]
        todo.due = date
        todo.notified = nil  // 시각을 바꾸면 다시 알린다
        app.store.todos[dueIndex] = todo
    }

    @objc private func dueSet() { setDue(duePicker?.dateValue) }
    @objc private func dueClear() { setDue(nil) }
    @objc private func dueInHour() { setDue(Date().addingTimeInterval(3600)) }
    @objc private func dueTomorrow() {
        let cal = Calendar.current
        let tomorrow = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: Date()))!
        setDue(cal.date(byAdding: .hour, value: 9, to: tomorrow))
    }

    // MARK: Control actions

    @objc private func lookChanged(_ sender: NSSegmentedControl) { app.setDesign(sender.selectedSegment) }
    @objc private func sizeChanged(_ sender: NSSegmentedControl) { app.setSize(sender.selectedSegment) }

    @objc private func sliderChanged(_ sender: NSSlider) {
        guard let key = sender.identifier?.rawValue else { return }
        app.setTunable(key, key == "pace" ? -sender.doubleValue : sender.doubleValue)
    }

    @objc private func lengthsChanged() {
        let f = (controls["fo.len"] as? NSSegmentedControl)?.selectedSegment ?? -1
        let b = (controls["fo.brk"] as? NSSegmentedControl)?.selectedSegment ?? -1
        app.setFocusLengths(focus: Self.focusChoices.indices.contains(f) ? Self.focusChoices[f] : app.focusMinutes,
                            rest: Self.breakChoices.indices.contains(b) ? Self.breakChoices[b] : app.breakMinutes)
    }

    @objc private func loginChanged(_ sender: NSButton) {
        do {
            if sender.state == .on {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            loginNote = ""
        } catch {
            loginNote = "Couldn't change this: \(error.localizedDescription)"
        }
        refresh()
    }

    // MARK: Status item menu

    func menuNeedsUpdate(_ menu: NSMenu) {
        guard menu === statusMenu else { return }
        menu.removeAllItems()
        func add(_ title: String, _ action: Selector, target: AnyObject) -> NSMenuItem {
            let item = menu.addItem(withTitle: title, action: action, keyEquivalent: "")
            item.target = target
            return item
        }
        if app.ringing { _ = add("Stop Ringing", #selector(AppDelegate.stopRinging), target: app) }
        _ = add("Open Pixel Cat", #selector(showFromMenu), target: self)
        _ = add("New To-Do…", #selector(quickAdd), target: self)
        _ = add("New Note", #selector(newNote), target: self)
        menu.addItem(.separator())
        let open = app.store.todos.indices.filter { !app.store.todos[$0].done }
        if open.isEmpty {
            menu.addItem(withTitle: "Nothing left to do", action: nil, keyEquivalent: "")
        } else {
            let head = menu.addItem(withTitle: "Mark as done", action: nil, keyEquivalent: "")
            head.isEnabled = false
            for i in open.prefix(8) {
                let item = add(app.store.todos[i].text, #selector(menuDone(_:)), target: self)
                item.tag = i
                item.indentationLevel = 1
            }
            if open.count > 8 { menu.addItem(withTitle: "…and \(open.count - 8) more", action: nil, keyEquivalent: "") }
        }
        menu.addItem(.separator())
        let focus = app.focusEnds != nil ? "Pause \(app.focusPhase == .rest ? "Break" : "Focus") (\(clock(app.focusLeft)))"
            : app.focusPhase == .idle ? "Start Focus (\(app.focusMinutes) min)" : "Resume (\(clock(app.focusLeft)))"
        _ = add(focus, #selector(AppDelegate.toggleFocus), target: app)
        if app.focusPhase != .idle { _ = add("Reset Focus", #selector(AppDelegate.resetFocus), target: app) }
        menu.addItem(.separator())
        _ = add("Put Out Food", #selector(AppDelegate.putFood), target: app)
        _ = add(app.ballPanel.isVisible ? "Put Away Yarn Ball" : "Throw Yarn Ball", #selector(AppDelegate.toggleBall), target: app)
        _ = add(app.asleep ? "Wake Up" : "Put to Sleep", #selector(AppDelegate.toggleSleep), target: app)
        menu.addItem(.separator())
        _ = add("Quit Pixel Cat", #selector(AppDelegate.quit), target: app)
    }

    @objc private func showFromMenu() { show() }

    @objc private func menuDone(_ sender: NSMenuItem) {
        guard app.store.todos.indices.contains(sender.tag) else { return }
        app.store.todos[sender.tag].done = true
    }

    // MARK: Main menu

    private func installMainMenu() {
        let main = NSMenu()
        func submenu(_ title: String) -> NSMenu {
            let item = NSMenuItem()
            main.addItem(item)
            let menu = NSMenu(title: title)
            item.submenu = menu
            return menu
        }
        @discardableResult
        func add(_ menu: NSMenu, _ title: String, _ action: Selector?, _ key: String = "",
                 target: AnyObject? = nil, shift: Bool = false) -> NSMenuItem {
            let item = menu.addItem(withTitle: title, action: action, keyEquivalent: key)
            item.target = target
            if shift { item.keyEquivalentModifierMask = [.command, .shift] }
            return item
        }

        let appMenu = submenu("Pixel Cat")
        add(appMenu, "About Pixel Cat", #selector(NSApplication.orderFrontStandardAboutPanel(_:)))
        appMenu.addItem(.separator())
        add(appMenu, "Settings…", #selector(showSettings), ",", target: self)
        appMenu.addItem(.separator())
        add(appMenu, "Hide Pixel Cat", #selector(NSApplication.hide(_:)), "h")
        add(appMenu, "Quit Pixel Cat", #selector(AppDelegate.quit), "q", target: app)

        let file = submenu("File")
        add(file, "New To-Do", #selector(newTodo), "n", target: self)
        add(file, "Quick Add…", #selector(quickAdd), "n", target: self, shift: true)
        add(file, "New Note", #selector(newNote), "n", target: self).keyEquivalentModifierMask = [.command, .option]
        file.addItem(.separator())
        add(file, "Clear Completed", #selector(AppDelegate.clearDone), target: app)
        file.addItem(.separator())
        add(file, "Close Window", #selector(NSWindow.performClose(_:)), "w")

        let edit = submenu("Edit")
        add(edit, "Undo", Selector(("undo:")), "z")
        add(edit, "Redo", Selector(("redo:")), "z", shift: true)
        edit.addItem(.separator())
        add(edit, "Cut", #selector(NSText.cut(_:)), "x")
        add(edit, "Copy", #selector(NSText.copy(_:)), "c")
        add(edit, "Paste", #selector(NSText.paste(_:)), "v")
        add(edit, "Select All", #selector(NSText.selectAll(_:)), "a")

        let view = submenu("View")
        for (i, name) in Self.pageNames.enumerated() {
            add(view, name, #selector(menuPage(_:)), "\(i + 1)", target: self).tag = i
        }
        view.addItem(.separator())
        add(view, "Show or Hide To-Dos on Cat", #selector(AppDelegate.toggleTodoBubble), "b", target: app)

        let focus = submenu("Focus")
        add(focus, "Start or Pause", #selector(AppDelegate.toggleFocus), "f", target: app, shift: true)
        add(focus, "Reset", #selector(AppDelegate.resetFocus), target: app)

        let cat = submenu("Cat")
        add(cat, "Put Out Food", #selector(AppDelegate.putFood), "e", target: app, shift: true)
        add(cat, "Throw or Put Away Yarn Ball", #selector(AppDelegate.toggleBall), "y", target: app, shift: true)
        add(cat, "Put to Sleep or Wake Up", #selector(AppDelegate.toggleSleep), target: app)
        cat.addItem(.separator())
        add(cat, "Climb a Window", #selector(AppDelegate.climbWindow), target: app)
        add(cat, "Come Down", #selector(AppDelegate.comeDown), target: app)

        let windowMenu = submenu("Window")
        add(windowMenu, "Minimize", #selector(NSWindow.performMiniaturize(_:)), "m")
        add(windowMenu, "Zoom", #selector(NSWindow.performZoom(_:)))
        NSApp.windowsMenu = windowMenu
        NSApp.mainMenu = main
    }

    @objc private func menuPage(_ sender: NSMenuItem) { show(page: sender.tag) }
    @objc private func showSettings() { show(page: 7) }

    @objc private func newNote() {
        show(page: 2)
        notesPane.newNote()
    }

    @objc private func newTodo() {
        show(page: 1)
        window?.makeFirstResponder(addField)
    }

    // MARK: Quick add

    // 어느 앱에서든 Control-Option-T 로 뜨는 한 줄 입력 창
    private func installHotKey() {
        var ref: EventHotKeyRef?
        let id = EventHotKeyID(signature: OSType(0x5043_4154), id: 1)  // 'PCAT'
        RegisterEventHotKey(UInt32(kVK_ANSI_T), UInt32(controlKey | optionKey), id,
                            GetApplicationEventTarget(), 0, &ref)
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, _, _ in
            NotificationCenter.default.post(name: Notification.Name("PixelCatHotKey"), object: nil)
            return noErr
        }, 1, &spec, nil, nil)
    }

    @objc func quickAdd() {
        if quickPanel == nil {
            let panel = KeyPanel(contentRect: NSRect(x: 0, y: 0, width: 520, height: 56),
                                 styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
            panel.isOpaque = false
            panel.backgroundColor = .clear
            panel.hasShadow = true
            panel.level = .modalPanel
            panel.hidesOnDeactivate = false
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            panel.delegate = self

            let glass = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 520, height: 56))
            glass.material = .hudWindow
            glass.state = .active
            glass.wantsLayer = true
            glass.layer?.cornerRadius = 14
            glass.layer?.masksToBounds = true

            let field = NSTextField(frame: NSRect(x: 18, y: 14, width: 484, height: 28))
            field.isBordered = false
            field.drawsBackground = false
            field.focusRingType = .none
            field.font = .systemFont(ofSize: 20)
            field.placeholderString = "New to-do   ·   Return to add, Esc to close"
            field.delegate = self
            glass.addSubview(field)
            panel.contentView = glass
            quickPanel = panel
            quickField = field
        }
        guard let panel = quickPanel, let screen = NSScreen.main?.visibleFrame else { return }
        quickField?.stringValue = ""
        panel.setFrameOrigin(NSPoint(x: screen.midX - 260, y: screen.minY + screen.height * 0.68))
        panel.makeKeyAndOrderFront(nil)
        panel.makeFirstResponder(quickField)
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        guard control === quickField else { return false }
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            addTodo(control.stringValue)
            quickPanel?.orderOut(nil)
            return true
        }
        if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            quickPanel?.orderOut(nil)
            return true
        }
        return false
    }

    // 시험용: 첫 할 일의 ⏰ 를 누르고 몇 초 뒤로 정한 다음 Set 을 누른 것과 같은 경로를 탄다
    func testSetDue(after seconds: TimeInterval) -> Bool {
        show(page: 1)
        guard let t = table, t.numberOfRows > 0,
              let button = t.view(atColumn: 2, row: 0, makeIfNecessary: true) as? NSButton else { return false }
        showDue(button)
        duePicker?.dateValue = Date().addingTimeInterval(seconds)
        dueSet()
        return app.store.todos.first?.due != nil
    }

    // MARK: Snapshots (모양 확인용)

    // 각 화면을 밝은 모드로 그려서 PNG 로 저장한다
    func snapshotAll(to dir: String) {
        show()
        window?.appearance = NSAppearance(named: .aqua)
        func snap(_ i: Int) {
            guard i < pages.count else { return }
            select(i)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                if let view = self?.window?.contentView, let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) {
                    view.cacheDisplay(in: view.bounds, to: rep)
                    try? rep.representation(using: .png, properties: [:])?
                        .write(to: URL(fileURLWithPath: "\(dir)/page-\(i).png"))
                }
                snap(i + 1)
            }
        }
        snap(0)
    }
}
