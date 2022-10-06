class Card:
    #The card class creats a card with a suit, name and value

    def __init__(self, suit, name, value):
        self.suit = suit
        self.name = name
        self.value = value
        self.image = ""

    def print(self):
        self.image = "{}_of_{}".format(self.name, self.suit)
        print("{}_of_{}".format(self.name, self.suit).upper())
        return self.image.upper()
