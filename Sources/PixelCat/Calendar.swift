import Cocoa

// 달력 화면의 뼈대: 한 달 달력에 마감이 있는 날을 점으로 찍고, 날짜를 누르면 그날 할 일을 보여 준다.
// 지금은 앱 안의 할 일만 보여 준다. 나중에 애플 캘린더 일정을 붙일 때는 items 에 그 일정을 더해 주면 된다

struct CalendarItem {
    let date: Date
    let title: String
    let done: Bool
}

final class MonthView: NSView {
    var month = Date() { didSet { needsDisplay = true } }      // 보여 줄 달 안의 아무 날
    var selected = Date() { didSet { needsDisplay = true } }
    var marked: Set<Date> = [] { didSet { needsDisplay = true } }  // 일정이 있는 날 (그날 0시)
    var onSelect: ((Date) -> Void)?

    private let cal = Calendar.current
    private let headerHeight: CGFloat = 24

    override var isFlipped: Bool { true }

    private var firstDay: Date { cal.date(from: cal.dateComponents([.year, .month], from: month)) ?? month }
    private var offset: Int { cal.component(.weekday, from: firstDay) - 1 }  // 일요일부터 시작
    private var dayCount: Int { cal.range(of: .day, in: .month, for: firstDay)?.count ?? 30 }
    private var cell: NSSize { NSSize(width: bounds.width / 7, height: (bounds.height - headerHeight) / 6) }

    override func draw(_ dirtyRect: NSRect) {
        let names = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        for (i, name) in names.enumerated() {
            let attrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 10, weight: .semibold), .foregroundColor: NSColor.secondaryLabelColor,
            ]
            let w = (name as NSString).size(withAttributes: attrs).width
            (name as NSString).draw(at: NSPoint(x: CGFloat(i) * cell.width + (cell.width - w) / 2, y: 4), withAttributes: attrs)
        }
        let today = cal.startOfDay(for: Date()), chosen = cal.startOfDay(for: selected)
        for day in 1...dayCount {
            guard let date = cal.date(byAdding: .day, value: day - 1, to: firstDay) else { continue }
            let slot = day - 1 + offset
            let rect = NSRect(x: CGFloat(slot % 7) * cell.width, y: headerHeight + CGFloat(slot / 7) * cell.height,
                              width: cell.width, height: cell.height)
            let circle = NSRect(x: rect.midX - 14, y: rect.minY + 4, width: 28, height: 28)
            if date == today {
                NSColor.controlAccentColor.setFill()
                NSBezierPath(ovalIn: circle).fill()
            } else if date == chosen {
                NSColor.labelColor.withAlphaComponent(0.12).setFill()
                NSBezierPath(ovalIn: circle).fill()
            }
            if date == chosen && date == today {
                NSColor.labelColor.setStroke()
                let ring = NSBezierPath(ovalIn: circle.insetBy(dx: -2.5, dy: -2.5))
                ring.lineWidth = 1.5
                ring.stroke()
            }
            let attrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedDigitSystemFont(ofSize: 13, weight: date == today ? .bold : .regular),
                .foregroundColor: date == today ? NSColor.white : NSColor.labelColor,
            ]
            let text = "\(day)" as NSString
            let size = text.size(withAttributes: attrs)
            text.draw(at: NSPoint(x: circle.midX - size.width / 2, y: circle.midY - size.height / 2), withAttributes: attrs)
            if marked.contains(date) {
                ringPink.setFill()
                NSBezierPath(ovalIn: NSRect(x: rect.midX - 3, y: circle.maxY + 3, width: 6, height: 6)).fill()
            }
        }
    }

    override func mouseDown(with event: NSEvent) {
        let p = convert(event.locationInWindow, from: nil)
        guard p.y > headerHeight else { return }
        let slot = Int((p.y - headerHeight) / cell.height) * 7 + Int(p.x / cell.width)
        let day = slot - offset + 1
        guard (1...dayCount).contains(day), let date = cal.date(byAdding: .day, value: day - 1, to: firstDay) else { return }
        selected = date
        onSelect?(date)
    }
}

final class CalendarPane: NSObject {
    let view = NSView()
    private let items: () -> [CalendarItem]
    private let monthView = MonthView()
    private let title = NSTextField(labelWithString: "")
    private let dayTitle = NSTextField(labelWithString: "")
    private let dayList = NSTextField(labelWithString: "")
    private let cal = Calendar.current
    private let english = Locale(identifier: "en_US")

    init(items: @escaping () -> [CalendarItem]) {
        self.items = items
        super.init()
        build()
        reload()
    }

    private func build() {
        let heading = NSTextField(labelWithString: "Calendar")
        heading.font = .systemFont(ofSize: 26, weight: .bold)
        title.font = .systemFont(ofSize: 16, weight: .semibold)
        let prev = NSButton(title: "‹", target: self, action: #selector(previousMonth))
        let today = NSButton(title: "Today", target: self, action: #selector(goToday))
        let next = NSButton(title: "›", target: self, action: #selector(nextMonth))
        let spacer = NSView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let bar = NSStackView(views: [title, spacer, prev, today, next])
        bar.spacing = 8

        monthView.onSelect = { [weak self] _ in self?.reload() }
        dayTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        dayList.maximumNumberOfLines = 6
        dayList.textColor = .secondaryLabelColor
        let note = NSTextField(labelWithString: "Shows to-do reminders from this app. Apple and Google Calendar are not connected yet.")
        note.font = .systemFont(ofSize: 11)
        note.textColor = .tertiaryLabelColor

        for v in [heading, bar, monthView, dayTitle, dayList, note] as [NSView] {
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
        }
        NSLayoutConstraint.activate([
            heading.topAnchor.constraint(equalTo: view.topAnchor),
            heading.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.topAnchor.constraint(equalTo: heading.bottomAnchor, constant: 12),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            monthView.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: 10),
            monthView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            monthView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            monthView.heightAnchor.constraint(equalToConstant: 300),
            dayTitle.topAnchor.constraint(equalTo: monthView.bottomAnchor, constant: 12),
            dayTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dayList.topAnchor.constraint(equalTo: dayTitle.bottomAnchor, constant: 6),
            dayList.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dayList.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
            note.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            note.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    @objc private func previousMonth() { shift(-1) }
    @objc private func nextMonth() { shift(1) }

    private func shift(_ months: Int) {
        monthView.month = cal.date(byAdding: .month, value: months, to: monthView.month) ?? monthView.month
        reload()
    }

    @objc private func goToday() {
        monthView.month = Date()
        monthView.selected = Date()
        reload()
    }

    func reload() {
        let all = items()
        monthView.marked = Set(all.filter { !$0.done }.map { cal.startOfDay(for: $0.date) })

        let f = DateFormatter()
        f.locale = english
        f.dateFormat = "MMMM yyyy"
        title.stringValue = f.string(from: monthView.month)
        f.dateFormat = "EEEE, MMMM d"
        dayTitle.stringValue = f.string(from: monthView.selected)

        let day = cal.startOfDay(for: monthView.selected)
        let mine = all.filter { cal.startOfDay(for: $0.date) == day }.sorted { $0.date < $1.date }
        f.dateFormat = "h:mm a"
        dayList.stringValue = mine.isEmpty ? "Nothing due on this day."
            : mine.map { "\($0.done ? "✓" : "•") \(f.string(from: $0.date))  \($0.title)" }.joined(separator: "\n")
    }
}
