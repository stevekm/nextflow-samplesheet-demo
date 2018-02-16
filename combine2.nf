first = Channel.from(1)
second = Channel.from(2)

first.combine(second).println()
