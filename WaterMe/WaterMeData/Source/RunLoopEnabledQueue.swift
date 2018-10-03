//
//  RunLoopEnabledQueue.swift
//  WaterMeData
//
//  Created by Jeffrey Bergier on 10/2/18.
//  Copyright © 2018 Saturday Apps.
//
//  This file is part of WaterMe.  Simple Plant Watering Reminders for iOS.
//
//  WaterMe is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  WaterMe is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public class RunLoopEnabledQueue: NSObject {

    public let name: String
    public let priority: QualityOfService
    private(set) var thread: Thread!

    private var currentBlock: (() -> Void)?

    public init(name: String, priority: QualityOfService) {
        self.name = name
        self.priority = priority
        super.init()
        let thread = Thread(block: { [weak self] in
            guard let thread = self?.thread else { return }
            while self != nil && !thread.isCancelled {
                RunLoop.current.run(mode: .default, before: Date.distantFuture)
            }
        })
        thread.name = name
        thread.qualityOfService = priority
        self.thread = thread
        self.thread.start()
    }

    @objc private func runBlock() {
        assert(Thread.isMainThread == false && Thread.current === self.thread)
        self.currentBlock?()
        self.currentBlock = nil
    }

    public func execute(async: Bool = true, block: @escaping () -> Void) {
        self.currentBlock = block
        self.perform(#selector(self.runBlock),
                     on: self.thread,
                     with: nil,
                     waitUntilDone: !async,
                     modes: [RunLoop.Mode.default.rawValue])
    }
}
