local Translations = {
    error = {
        nowin = 'Man Man Man. Miserie Miserie Miserie..',
        placebet = 'Je zette €%{value} in..',
        nomoney = 'Ale makker kga geen gratis geld geven he!',
    },
    success = {
        win = 'Allej, hier is u winst..',
        getreward = 'De man gaf je x%{value} je geld dus je kreeg €%{value2}'
    },
    info = {
        play = 'Speel voor €%{value}',
        start = 'Start de ronde',
        choose = 'Kies %{value}',
        arrest = 'Arresteer Scammer',
        howtoplay = 'Kies (met je oogspier) 1 van de 3 potjes en win!'
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
