import Cocoa

// Checks GitHub Releases for a newer version and, if the user agrees, downloads it, swaps the app bundle
// and relaunches. No third-party framework: the release zip is fetched over HTTPS from this app's own repository
// and checked (bundle identifier, version, code signature, signing team) before anything is replaced.

final class Updater {
    static let repository = "sparkingwaterr/do_it_meow.app"
    static var releasesPage: URL { URL(string: "https://github.com/\(repository)/releases/latest")! }

    private struct Release {
        let version: String
        let notes: String
        let page: URL
        let zip: URL?
    }

    private var checking = false
    // For testing the whole path without anyone clicking: install as soon as a newer release is found
    private let unattended = ProcessInfo.processInfo.environment["PIXELCAT_TEST_INSTALL"] != nil
    private var timer: Timer?

    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }

    var automatic: Bool {
        get { UserDefaults.standard.object(forKey: "autoUpdateCheck") == nil || UserDefaults.standard.bool(forKey: "autoUpdateCheck") }
        set { UserDefaults.standard.set(newValue, forKey: "autoUpdateCheck") }
    }

    // Check shortly after launch and then once a day, if the user has left automatic checks on
    func start() {
        guard !demoMode else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in self?.checkIfDue() }
        let t = Timer(timeInterval: 3600, repeats: true) { [weak self] _ in self?.checkIfDue() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func checkIfDue() {
        let last = UserDefaults.standard.double(forKey: "lastUpdateCheck")
        guard automatic, Date().timeIntervalSince1970 - last > 86400 else { return }
        check(userInitiated: false)
    }

    // "1.10.0" > "1.9": compare number by number
    static func isNewer(_ a: String, than b: String) -> Bool {
        func parts(_ s: String) -> [Int] {
            s.trimmingCharacters(in: CharacterSet(charactersIn: "vV")).split(separator: ".").map { Int($0.prefix { $0.isNumber }) ?? 0 }
        }
        let x = parts(a), y = parts(b)
        for i in 0..<max(x.count, y.count) {
            let l = i < x.count ? x[i] : 0, r = i < y.count ? y[i] : 0
            if l != r { return l > r }
        }
        return false
    }

    func check(userInitiated: Bool) {
        guard !checking else { return }
        checking = true
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastUpdateCheck")
        var request = URLRequest(url: URL(string: "https://api.github.com/repos/\(Self.repository)/releases/latest")!)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self else { return }
                self.checking = false
                guard error == nil, (response as? HTTPURLResponse)?.statusCode == 200, let data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let tag = json["tag_name"] as? String,
                      let page = (json["html_url"] as? String).flatMap(URL.init(string:)) else {
                    log("update check failed: \(error?.localizedDescription ?? "bad response")")
                    if userInitiated {
                        self.alert("Couldn't check for updates", "Check your internet connection and try again.")
                    }
                    return
                }
                let assets = json["assets"] as? [[String: Any]] ?? []
                let zip = assets.first { ($0["name"] as? String)?.hasSuffix(".zip") == true }
                    .flatMap { $0["browser_download_url"] as? String }.flatMap(URL.init(string:))
                let release = Release(version: tag.trimmingCharacters(in: CharacterSet(charactersIn: "vV")),
                                      notes: json["body"] as? String ?? "", page: page, zip: zip)
                log("latest release \(release.version), running \(self.currentVersion)")
                if Self.isNewer(release.version, than: self.currentVersion) {
                    if self.unattended, let zip = release.zip { return self.install(zip, release) }
                    if userInitiated || UserDefaults.standard.string(forKey: "skippedVersion") != release.version {
                        self.offer(release)
                    }
                } else if userInitiated {
                    self.alert("You're up to date", "Pixel Cat \(self.currentVersion) is the latest version.")
                }
            }
        }.resume()
    }

    private func alert(_ title: String, _ text: String) {
        NSApp.activate(ignoringOtherApps: true)
        let a = NSAlert()
        a.messageText = title
        a.informativeText = text
        a.runModal()
    }

    private func offer(_ release: Release) {
        NSApp.activate(ignoringOtherApps: true)
        let a = NSAlert()
        a.messageText = "Pixel Cat \(release.version) is available"
        let notes = release.notes.split(separator: "\n").prefix(12).joined(separator: "\n")
        a.informativeText = "You have \(currentVersion).\n\n\(notes)"
        a.addButton(withTitle: release.zip == nil ? "View Release" : "Install and Relaunch")
        a.addButton(withTitle: "Later")
        a.addButton(withTitle: "Skip This Version")
        switch a.runModal() {
        case .alertFirstButtonReturn:
            if let zip = release.zip {
                install(zip, release)
            } else {
                NSWorkspace.shared.open(release.page)
            }
        case .alertThirdButtonReturn:
            UserDefaults.standard.set(release.version, forKey: "skippedVersion")
        default:
            break
        }
    }

    private func run(_ tool: String, _ arguments: [String]) -> (status: Int32, output: String) {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: tool)
        p.arguments = arguments
        let pipe = Pipe()
        p.standardOutput = pipe
        p.standardError = pipe
        do { try p.run() } catch { return (-1, "") }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        p.waitUntilExit()
        return (p.terminationStatus, String(data: data, encoding: .utf8) ?? "")
    }

    // The signing team of an app bundle, or nil when it is unsigned or only ad-hoc signed
    private func team(of app: URL) -> String? {
        let line = run("/usr/bin/codesign", ["-dv", app.path]).output
            .split(separator: "\n").first { $0.hasPrefix("TeamIdentifier=") }
        let team = line.map { String($0.dropFirst("TeamIdentifier=".count)) }
        return team == "not set" ? nil : team
    }

    private func install(_ zip: URL, _ release: Release) {
        let fail: (String) -> Void = { [weak self] reason in
            log("update failed: \(reason)")
            if self?.unattended == true { exit(1) }
            self?.alert("The update couldn't be installed", "\(reason)\n\nYou can download it yourself from the release page.")
            NSWorkspace.shared.open(release.page)
        }
        let destination = Bundle.main.bundleURL
        guard destination.pathExtension == "app",
              FileManager.default.isWritableFile(atPath: destination.deletingLastPathComponent().path) else {
            return fail("Pixel Cat can't replace itself where it is installed.")
        }
        URLSession.shared.downloadTask(with: zip) { [weak self] file, response, error in
            guard let self else { return }
            guard error == nil, (response as? HTTPURLResponse)?.statusCode == 200, let file else {
                return DispatchQueue.main.async { fail("The download failed.") }
            }
            let work = FileManager.default.temporaryDirectory.appendingPathComponent("PixelCatUpdate-\(UUID().uuidString)")
            try? FileManager.default.createDirectory(at: work, withIntermediateDirectories: true)
            let unzip = self.run("/usr/bin/ditto", ["-x", "-k", file.path, work.path])
            let fresh = work.appendingPathComponent(destination.lastPathComponent)
            let info = NSDictionary(contentsOf: fresh.appendingPathComponent("Contents/Info.plist"))

            // Refuse anything that is not clearly a newer, intact copy of this same app
            var problem: String?
            if unzip.status != 0 || info == nil {
                problem = "The download couldn't be unpacked."
            } else if info?["CFBundleIdentifier"] as? String != Bundle.main.bundleIdentifier {
                problem = "The download isn't Pixel Cat."
            } else if !Self.isNewer(info?["CFBundleShortVersionString"] as? String ?? "0", than: self.currentVersion) {
                problem = "The download isn't newer than this version."
            } else if self.run("/usr/bin/codesign", ["--verify", "--deep", "--strict", fresh.path]).status != 0 {
                problem = "The download's code signature is not valid."
            } else if let mine = self.team(of: destination), self.team(of: fresh) != mine {
                problem = "The download was signed by someone else."
            }
            if let problem { return DispatchQueue.main.async { fail(problem) } }

            // A helper waits for this app to quit, swaps the bundle (keeping the old one until the copy succeeds)
            // and opens the new version
            let script = work.appendingPathComponent("swap.sh")
            let body = """
            #!/bin/sh
            while kill -0 \(ProcessInfo.processInfo.processIdentifier) 2>/dev/null; do sleep 0.2; done
            OLD="\(work.path)/old.app"
            mv "\(destination.path)" "$OLD" || exit 1
            if /usr/bin/ditto "\(fresh.path)" "\(destination.path)"; then
                /usr/bin/open "\(destination.path)"
            else
                mv "$OLD" "\(destination.path)"
                /usr/bin/open "\(destination.path)"
            fi
            """
            do {
                try body.write(to: script, atomically: true, encoding: .utf8)
            } catch {
                return DispatchQueue.main.async { fail("The installer couldn't be prepared.") }
            }
            DispatchQueue.main.async {
                let helper = Process()
                helper.executableURL = URL(fileURLWithPath: "/bin/sh")
                helper.arguments = [script.path]
                do {
                    try helper.run()
                } catch {
                    return fail("The installer couldn't be started.")
                }
                log("update \(release.version) staged, relaunching")
                UserDefaults.standard.synchronize()
                NSApp.terminate(nil)
            }
        }.resume()
    }
}
