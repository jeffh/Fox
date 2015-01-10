import Foundation

/* Needs tests and generator type rewriting first.
public struct TypedSequence<T> {
    var seq: FOXSequenceProtocol
    init(_ seq: FOXSequenceProtocol) {
        self.seq = seq
    }

    public var objcSequence: FOXSequenceProtocol { return seq }

    public var firstObject: T? { return seq.firstObject() as T? }
    public var remainingSequence: TypedSequence<T>? {
        if let seq = seq.remainingSequence() {
            return TypedSequence<T>(seq)
        }
        return nil
    }
    public var count: UInt { return seq.count() }

    public func map<E: AnyObject>(fn: (T) -> E) -> TypedSequence<E> {
        return TypedSequence<E>(seq.sequenceByMapping { fn($0 as T) })
    }

    public func mapIndex<E: AnyObject>(fn: (UInt, T) -> E) -> TypedSequence<E> {
        return TypedSequence<E>(seq.sequenceByMappingWithIndex { fn($0, $1 as T) })
    }

    public func mapIndex<E: AnyObject>(fn: (UInt, T) -> E, startingIndex: UInt) -> TypedSequence<E> {
        return TypedSequence<E>(seq.sequenceByMappingWithIndex(({
            fn($0, $1 as T)
        }), startingIndex: startingIndex))
    }

    public func filter(fn: (T) -> Bool) -> TypedSequence<T> {
        return TypedSequence<T>(seq.sequenceByFiltering { fn($0 as T) })
    }

    public func append(appendedSeq: TypedSequence<T>) -> TypedSequence<T> {
        return TypedSequence<T>(seq.sequenceByAppending(appendedSeq.seq))
    }

    public func dropIndex(index: UInt) -> TypedSequence<T> {
        return TypedSequence<T>(seq.sequenceByDroppingIndex(index))
    }

    public func mapcat<E>(fn: (T) -> TypedSequence<E>) -> TypedSequence<E> {
        return TypedSequence<E>(seq.sequenceByMapcatting { fn($0 as T).seq })
    }

    public func reduce<E: AnyObject>(seed: E, fn: (E, T) -> E) -> E {
        return seq.objectByReducingWithSeed(seed, reducer: ({ fn($0 as E, $1 as T) })) as E
    }
}

public func map<T, E: AnyObject>(seq: TypedSequence<T>, fn: (T) -> E) -> TypedSequence<E> {
    return seq.map(fn)
}

public func filter<T>(seq: TypedSequence<T>, fn: (T) -> Bool) -> TypedSequence<T> {
    return seq.filter(fn)
}

public struct TypedRoseTree<T> {
    var tree: FOXRoseTree

    init(_ tree: FOXRoseTree) {
        self.tree = tree
    }

    public var value: T? { return tree.value as T? }
    public var children: TypedSequence<TypedRoseTree<T>> {
        return TypedSequence<TypedRoseTree<T>>(tree.children)
    }

    public func map<E: AnyObject>(fn: (T) -> E) -> TypedRoseTree<E> {
        return TypedRoseTree<E>(tree.treeByApplyingBlock { fn($0 as T) })
    }

    public func filterChildren(fn: (T) -> Bool) -> TypedRoseTree<T> {
        return TypedRoseTree<T>(tree.treeFilterChildrenByBlock { fn($0 as T) })
    }
}

public func map<T, E: AnyObject>(tree: TypedRoseTree<T>, fn: (T) -> E) -> TypedRoseTree<E> {
    return tree.map(fn)
}


public struct TypedGenerator<T> {
    var generator: FOXGenerator

    init(_ generator: FOXGenerator) {
        self.generator = generator
    }

    public func lazyTree(random: FOXRandom, maximumSize: UInt) -> TypedRoseTree<T> {
        let roseTree = generator.lazyTreeWithRandom(random, maximumSize: maximumSize)
        return TypedRoseTree<T>(roseTree)
    }
}

*/