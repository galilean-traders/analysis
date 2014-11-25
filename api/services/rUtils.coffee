module.exports =
    filter_NA: (r_data) ->
        JSON.parse "#{r_data}"
            .map (d, i) -> 
                index: i
                value: d
            .filter (d) -> d.value isnt "NA"
