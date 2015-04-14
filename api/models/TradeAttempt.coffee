# model that stores the analyzed signals to the DB

module.exports =
    attributes:
        user:
            model: "user"
        instrument:
            type: "string"
        time:
            type: "string"
        adr:
            type: "boolean"
        stoch:
            type: "string"
            enum: ["buy", "sell", "false"]
        ema5ema10:
            type: "string"
            enum: ["buy", "sell", "false"]
        rsi:
            type: "string"
            enum: ["buy", "sell", "false"]
        status:
            type: "boolean" # was a trade triggered?
