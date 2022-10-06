class Player:
    # Creates the player that the user will control. The player can request cards
    # which will be summed to a value that determines whether they win or lose

    def __init__(self):
        self.cards = []
        self.count = 0
        self.hand_value = 0
        self.ace_in_hand = False

    def request(self, top_card, deck):
        self.cards.append(deck[top_card])
        if deck[top_card].name == "ace":
            deck[top_card].value = 11
            self.ace_in_hand = True

    def print_hand(self):
        for k in range(len(self.cards)):
            self.cards[k].print()

    def get_hand_value(self):
        self.hand_value = 0

        for k in range(len(self.cards)):
            self.hand_value += self.cards[k].value

        if self.ace_in_hand:
            if self.hand_value > 21:
                self.hand_value -= 11

        return self.hand_value

