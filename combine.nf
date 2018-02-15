left = Channel.from(['A',1], ['B',2], ['A',3])
z = Channel.from(["x", "y", "z"])
left.combine(z).println()
