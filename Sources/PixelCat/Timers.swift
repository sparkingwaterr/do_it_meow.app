import Cocoa

// 타이머 화면: 몇 분 뒤에 울릴지 정해 두면 시간이 다 됐을 때 고양이가 달려와서 울린다. 여러 개를 함께 돌릴 수 있다

struct CountdownTimer: Codable {
    var id = UUID()
    var label = ""
    var total: TimeInterval      // 처음 맞춘 길이
    var ends: Date?              // 돌아가는 중이면 끝나는 시각
    var remaining: TimeInterval  // 멈춰 있을 때 남은 시간

    var running: Bool { ends != nil }
    func left(at now: Date) -> TimeInterval { ends.map { max(0, $0.timeIntervalSince(now)) } ?? remaining }

    static func clock(_ t: TimeInterval) -> String {
        let s = Int(t.rounded(.up))
        return s >= 3600 ? String(format: "%d:%02d:%02d", s / 3600, s / 60 % 60, s % 60)
            : String(format: "%d:%02d", s / 60, s % 60)
    }

    var lengthText: String {
        let m = Int(total) / 60, s = Int(total) % 60
        return s == 0 ? "\(m) min" : m == 0 ? "\(s) sec" : "\(m) min \(s) sec"
    }
}

final class TimersPane: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    private(set) var timers: [CountdownTimer] = []
    let view = NSView()
    var onTest: (() -> Void)?
    var onChange: (() -> Void)?

    private let table = NSTableView()
    private let minutesField = NSTextField()
    private let labelField = NSTextField()
    private let empty = NSTextField(labelWithString: "No timers running. Press a length above to start one.")
    static let presets = [1, 3, 5, 10, 15, 30, 60]

    override init() {
        super.init()
        if let data = UserDefaults.standard.data(forKey: "timers"),
           let saved = try? JSONDecoder().decode([CountdownTimer].self, from: data) {
            timers = saved
        }
        build()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(timers) { UserDefaults.standard.set(data, forKey: "timers") }
        UserDefaults.standard.synchronize()
        empty.isHidden = !timers.isEmpty
        onChange?()
    }

    private func build() {
        let heading = NSTextField(labelWithString: "Timers")
        heading.font = .systemFont(ofSize: 26, weight: .bold)

        // 자주 쓰는 길이는 누르면 바로 시작한다
        let presetButtons = Self.presets.map { minutes -> NSButton in
            let b = NSButton(title: "\(minutes) min", target: self, action: #selector(startPreset(_:)))
            b.tag = minutes
            return b
        }
        let presets = NSStackView(views: presetButtons)
        presets.spacing = 6

        minutesField.placeholderString = "Minutes"
        minutesField.widthAnchor.constraint(equalToConstant: 80).isActive = true
        minutesField.target = self
        minutesField.action = #selector(startCustom)
        labelField.placeholderString = "Label (optional)"
        labelField.widthAnchor.constraint(equalToConstant: 200).isActive = true
        let custom = NSStackView(views: [minutesField, labelField,
                                         NSButton(title: "Start Timer", target: self, action: #selector(startCustom))])
        custom.spacing = 8
        let hint = NSTextField(labelWithString: "The label is used for preset buttons too. When a timer ends, click the cat to stop the ringing.")
        hint.font = .systemFont(ofSize: 11)
        hint.textColor = .secondaryLabelColor

        table.headerView = nil
        table.rowHeight = 44
        table.selectionHighlightStyle = .none
        table.backgroundColor = .clear
        for (id, width) in [("time", 130.0), ("info", 240.0), ("pause", 80.0), ("del", 24.0)] {
            let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(id))
            col.width = CGFloat(width)
            if id == "info" {
                col.resizingMask = .autoresizingMask
            } else {
                col.minWidth = CGFloat(width)
                col.maxWidth = CGFloat(width)
                col.resizingMask = []
            }
            table.addTableColumn(col)
        }
        table.dataSource = self
        table.delegate = self
        let list = NSScrollView()
        list.documentView = table
        list.hasVerticalScroller = true
        list.drawsBackground = false

        let test = NSButton(title: "Test Ring", target: self, action: #selector(testRing))
        empty.textColor = .secondaryLabelColor
        empty.isHidden = !timers.isEmpty

        for v in [heading, presets, custom, hint, list, test, empty] as [NSView] {
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
        }
        NSLayoutConstraint.activate([
            heading.topAnchor.constraint(equalTo: view.topAnchor),
            heading.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            presets.topAnchor.constraint(equalTo: heading.bottomAnchor, constant: 12),
            presets.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            custom.topAnchor.constraint(equalTo: presets.bottomAnchor, constant: 10),
            custom.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hint.topAnchor.constraint(equalTo: custom.bottomAnchor, constant: 8),
            hint.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            list.topAnchor.constraint(equalTo: hint.bottomAnchor, constant: 12),
            list.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            list.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            list.bottomAnchor.constraint(equalTo: test.topAnchor, constant: -12),
            test.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            test.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            empty.centerXAnchor.constraint(equalTo: list.centerXAnchor),
            empty.topAnchor.constraint(equalTo: list.topAnchor, constant: 40),
        ])
    }

    func start(seconds: TimeInterval, label: String) {
        guard seconds > 0 else { return }
        timers.append(CountdownTimer(label: label, total: seconds, ends: Date() + seconds, remaining: seconds))
        save()
        table.reloadData()
    }

    private var typedLabel: String { labelField.stringValue.trimmingCharacters(in: .whitespaces) }

    @objc private func startPreset(_ sender: NSButton) {
        start(seconds: TimeInterval(sender.tag * 60), label: typedLabel)
        labelField.stringValue = ""
    }

    @objc private func startCustom() {
        let text = minutesField.stringValue.replacingOccurrences(of: ",", with: ".")
        guard let minutes = Double(text), minutes > 0, minutes <= 24 * 60 else {
            NSSound.beep()
            return
        }
        start(seconds: (minutes * 60).rounded(), label: typedLabel)
        minutesField.stringValue = ""
        labelField.stringValue = ""
    }

    @objc private func testRing() { onTest?() }

    // 시간이 다 된 타이머가 있으면 목록에서 빼고, 말풍선에 쓸 글을 돌려준다. 매초 불린다
    func fire(at now: Date) -> String? {
        guard let i = timers.firstIndex(where: { $0.running && $0.left(at: now) <= 0 }) else { return nil }
        let t = timers.remove(at: i)
        save()
        table.reloadData()
        return t.label.isEmpty ? "Timer done · \(t.lengthText)" : "\(t.label) · \(t.lengthText) timer done"
    }

    // 가장 먼저 끝나는 타이머
    func soonest(at now: Date) -> (left: TimeInterval, timer: CountdownTimer)? {
        timers.filter(\.running).map { (left: $0.left(at: now), timer: $0) }.min { $0.left < $1.left }
    }

    // 창이 보이는 동안 매초 남은 시간만 다시 그린다
    func tick() {
        guard timers.contains(where: \.running), table.numberOfRows > 0 else { return }
        table.reloadData(forRowIndexes: IndexSet(integersIn: 0..<table.numberOfRows), columnIndexes: [0])
    }

    func numberOfRows(in tableView: NSTableView) -> Int { timers.count }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard timers.indices.contains(row) else { return nil }
        let t = timers[row]
        func centered(_ v: NSView) -> NSView {
            let cell = NSView()
            v.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(v)
            v.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive = true
            v.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            return cell
        }
        switch tableColumn?.identifier.rawValue {
        case "time":
            let l = NSTextField(labelWithString: CountdownTimer.clock(t.left(at: Date())))
            l.font = .monospacedDigitSystemFont(ofSize: 22, weight: .semibold)
            l.textColor = t.running ? .labelColor : .secondaryLabelColor
            return centered(l)
        case "info":
            let text = (t.label.isEmpty ? "" : t.label + "  ·  ") + t.lengthText + (t.running ? "" : "  ·  paused")
            let l = NSTextField(labelWithString: text)
            l.textColor = .secondaryLabelColor
            l.lineBreakMode = .byTruncatingTail
            return centered(l)
        case "pause":
            let b = NSButton(title: t.running ? "Pause" : "Resume", target: self, action: #selector(togglePause(_:)))
            b.controlSize = .small
            b.tag = row
            return centered(b)
        case "del":
            let b = NSButton(title: "×", target: self, action: #selector(delete(_:)))
            b.isBordered = false
            b.font = .systemFont(ofSize: 15, weight: .bold)
            b.contentTintColor = .tertiaryLabelColor
            b.toolTip = "Cancel this timer"
            b.tag = row
            return b
        default:
            return nil
        }
    }

    @objc private func togglePause(_ sender: NSButton) {
        guard timers.indices.contains(sender.tag) else { return }
        var t = timers[sender.tag]
        if let ends = t.ends {
            t.remaining = max(0, ends.timeIntervalSinceNow)
            t.ends = nil
        } else {
            t.ends = Date() + t.remaining
        }
        timers[sender.tag] = t
        save()
        table.reloadData()
    }

    @objc private func delete(_ sender: NSButton) {
        guard timers.indices.contains(sender.tag) else { return }
        timers.remove(at: sender.tag)
        save()
        table.reloadData()
    }
}
