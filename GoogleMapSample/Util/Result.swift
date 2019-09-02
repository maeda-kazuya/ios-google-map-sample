//
//  Result.swift
//
//  Created by Maeda Kazuya on 2019/01/13.
//  Copyright © 2019 Kazuya Maeda. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(T)
    case failure(Error)
}
