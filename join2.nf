Channel.from( ["A", "fooA", "barA"], ["B", "fooB", "barB"], ["C", "fooC", "barC"], ["D", "fooD", "barD"], ["E", "fooE", "barE"] ).into{ first; first2; first3 }
Channel.from( ["A", "B"], ["C", "D"], ["E", "D"] ).into{ second; second2; second3 }

second.join(first).println()
// second.join(first, by: [0]).join(first2, by: [1]).println()
second2.merge(first2).println()

// second3.groupBy

first3.join(second3).println()



Channel.from("Sample1", "Sample2", "Sample3", "Sample4", "Sample5", "Sample6")
        .map { item ->
            def file = "${item}.txt"
            return [item, file]
        }
        // .subscribe { println "${it}" }
        .into{samples; samples2; samples3; samples4}
Channel.from(["Sample1", "Sample2"], ["Sample3", "Sample4"], ["Sample6", "Sample4"])
        // .subscribe { println "${it}" }
        .into{sample_pairs; sample_pairs2}


sample_pairs.join(samples).join(samples2).println()
sample_pairs2.combine(samples3, by: 0).combine(samples4, by: 1).println()  //.combine(samples4, by: 1)
// sample_pairs2.join(samples3, by: 1).println()
// sample_pairs.mix(samples).println() //  .groupTuple()
