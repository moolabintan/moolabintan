import random
import Card


class Deck:
    #The Deck class creates 52 card objects and shuffles the deck that will be used to play the game



    def __init__(self):
        self.deck = self.create_deck()

    def create_deck(self):
        cards = []
        suits = ["Clubs", "Spades", "Diamonds", "Hearts"]
        name = ["ace","2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "queen", "king"]
        value = [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10]
        for k in range(len(suits)):
            for x in range(len(name)):
                cards.append(Card.Card(suits[k], name[x], value[x]))
        return cards

    # Mutates the deck by putting cards in random order
    def shuffle(self):
        for k in range(random.randint(1, 100)):
            for x in range(len(self.deck)):
                index1 = random.randint(0, 51)
                index2 = random.randint(0, 51)

                temp = self.deck[index1]
                self.deck[index1] = self.deck[index2]
                self.deck[index2] = temp

    def print_deck(self):
        for k in range(len(self.deck)):
            self.deck[k].print()
