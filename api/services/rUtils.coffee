module.exports =
    filter_NA: (r_data) ->
        JSON.parse "#{r_data}"
            .filter (d) -> d isnt "NA"
