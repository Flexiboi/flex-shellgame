local Translations = {
    error = {
        nowin = 'Rip, better luck next time..',
        placebet = 'You placed a bet of $%{value}..',
        nomoney = 'Not enough cash to play!',
    },
    success = {
        win = 'You won!',
        getreward = 'You won x%{value} your cash so $%{value2}'
    },
    info = {
        play = 'Play for $%{value}',
        start = 'Start playing',
        choose = 'Choose %{value}',
        arrest = 'Put in jail',
        howtoplay = 'Pick one of the 3 bowls and win!'
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
