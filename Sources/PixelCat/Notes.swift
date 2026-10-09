import Cocoa

// 메모 화면: 왼쪽에 메모 목록, 오른쪽에 글 쓰는 칸. 쓰는 대로 저장된다

struct Note: Codable {
    var id = UUID()
    var text = ""
    var updated = Date()

    // 첫 줄이 제목이 된다
    var title: String {
        let first = text.split(separator: "\n", omittingEmptySubsequences: true).first.map(String.init) ?? ""
        return first.trimmingCharacters(in: .whitespaces).isEmpty ? "New note" : first
    }
}

final class NotesPane: NSObject, NSTableViewDataSource, NSTableViewDelegate, NSTextViewDelegate {
    private(set) var notes: [Note] = []
    var onChange: (() -> Void)?  // 이 화면에서 메모가 바뀌었을 때 (고양이 말풍선이 따라 고친다)
    let view = NSView()
    private let table = NSTableView()
    private var textView: NSTextView!
    private let empty = NSTextField(labelWithString: "No notes yet. Press New Note to start one.")
    private let deleteButton = NSButton(title: "Delete", target: nil, action: nil)
    private let english = Locale(identifier: "en_US")

    override init() {
        super.init()
        if demoMode {
            notes = [
                Note(text: "Weekend ideas\n\n- Hike the river trail\n- Try the new ramen place\n- Fix the squeaky door",
                     updated: Date().addingTimeInterval(-900)),
                Note(text: "Meeting notes\n\nShip the beta on Friday. Ask Jun about the icon.",
                     updated: Date().addingTimeInterval(-86400)),
                Note(text: "Books to read\n\nThe Left Hand of Darkness\nPiranesi", updated: Date().addingTimeInterval(-3 * 86400)),
            ]
        } else if let data = UserDefaults.standard.data(forKey: "notes"),
           let saved = try? JSONDecoder().decode([Note].self, from: data) {
            notes = saved.sorted { $0.updated > $1.updated }  // 최근에 고친 것이 위로
        }
        build()
        if !notes.isEmpty { table.selectRowIndexes([0], byExtendingSelection: false) }
        showSelection()
    }

    private func save() {
        if demoMode { return }
        if let data = try? JSONEncoder().encode(notes) { UserDefaults.standard.set(data, forKey: "notes") }
        UserDefaults.standard.synchronize()  // 갑자기 꺼져도 남도록 바로 내려쓴다
    }

    private func build() {
        let heading = NSTextField(labelWithString: "Notes")
        heading.font = .systemFont(ofSize: 26, weight: .bold)
        let add = NSButton(title: "New Note", target: self, action: #selector(newNote))
        deleteButton.target = self
        deleteButton.action = #selector(deleteNote)
        let bar = NSStackView(views: [add, deleteButton])
        bar.spacing = 8

        table.headerView = nil
        table.rowHeight = 46
        table.backgroundColor = .clear
        table.style = .inset
        let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("note"))
        col.resizingMask = .autoresizingMask
        table.addTableColumn(col)
        table.dataSource = self
        table.delegate = self
        let list = NSScrollView()
        list.documentView = table
        list.hasVerticalScroller = true
        list.drawsBackground = false

        let editor = NSTextView.scrollableTextView()
        editor.borderType = .lineBorder
        textView = editor.documentView as? NSTextView
        textView.isRichText = false
        textView.font = .systemFont(ofSize: 14)
        textView.textContainerInset = NSSize(width: 10, height: 10)
        textView.allowsUndo = true
        textView.delegate = self

        empty.textColor = .secondaryLabelColor

        for v in [heading, bar, list, editor, empty] {
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
        }
        NSLayoutConstraint.activate([
            heading.topAnchor.constraint(equalTo: view.topAnchor),
            heading.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.topAnchor.constraint(equalTo: heading.bottomAnchor, constant: 12),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            list.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: 12),
            list.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            list.widthAnchor.constraint(equalToConstant: 200),
            list.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            editor.topAnchor.constraint(equalTo: list.topAnchor),
            editor.leadingAnchor.constraint(equalTo: list.trailingAnchor, constant: 12),
            editor.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            editor.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            empty.centerXAnchor.constraint(equalTo: editor.centerXAnchor),
            empty.centerYAnchor.constraint(equalTo: editor.centerYAnchor),
        ])
    }

    // 고른 메모를 오른쪽 칸에 띄운다
    private func showSelection() {
        let row = table.selectedRow
        let has = notes.indices.contains(row)
        textView.string = has ? notes[row].text : ""
        textView.isEditable = has
        empty.isHidden = !notes.isEmpty
        deleteButton.isEnabled = has
    }

    @objc func newNote() {
        notes.insert(Note(), at: 0)
        save()
        table.reloadData()
        table.selectRowIndexes([0], byExtendingSelection: false)
        showSelection()
        view.window?.makeFirstResponder(textView)
        onChange?()
    }

    // 고양이 말풍선에서 고친 글을 받아 적는다
    func update(_ index: Int, text: String) {
        guard notes.indices.contains(index) else { return }
        notes[index].text = text
        notes[index].updated = Date()
        save()
        table.reloadData(forRowIndexes: [index], columnIndexes: [0])
        if table.selectedRow == index { textView.string = text }
    }

    @objc private func deleteNote() {
        delete(at: table.selectedRow)
        onChange?()
    }

    func delete(at row: Int) {
        guard notes.indices.contains(row) else { return }
        let wasSelected = table.selectedRow
        notes.remove(at: row)
        save()
        table.reloadData()
        if !notes.isEmpty {
            table.selectRowIndexes([min(max(wasSelected, 0), notes.count - 1)], byExtendingSelection: false)
        }
        showSelection()
    }

    func numberOfRows(in tableView: NSTableView) -> Int { notes.count }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard notes.indices.contains(row) else { return nil }
        let title = NSTextField(labelWithString: notes[row].title)
        title.font = .systemFont(ofSize: 13, weight: .semibold)
        title.lineBreakMode = .byTruncatingTail
        let f = DateFormatter()
        f.locale = english
        f.doesRelativeDateFormatting = true
        f.dateStyle = .medium
        f.timeStyle = .short
        let date = NSTextField(labelWithString: f.string(from: notes[row].updated))
        date.font = .systemFont(ofSize: 10)
        date.textColor = .secondaryLabelColor
        let cell = NSView()
        for v in [title, date] {
            v.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(v)
            v.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 4).isActive = true
            v.trailingAnchor.constraint(lessThanOrEqualTo: cell.trailingAnchor, constant: -4).isActive = true
        }
        title.topAnchor.constraint(equalTo: cell.topAnchor, constant: 6).isActive = true
        date.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 2).isActive = true
        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) { showSelection() }

    func textDidChange(_ notification: Notification) {
        let row = table.selectedRow
        guard notes.indices.contains(row) else { return }
        notes[row].text = textView.string
        notes[row].updated = Date()
        save()
        table.reloadData(forRowIndexes: [row], columnIndexes: [0])  // 제목과 시각만 고친다
        onChange?()
    }
}
