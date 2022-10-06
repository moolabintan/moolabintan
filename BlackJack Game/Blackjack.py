import pygame
import random
import math


class Cards:
    def __init__(self, suit, name, value):
        self.suit = suit
        self.name = name
        self.value = value

    def print(self):
        print("{} of {}".format(self.name, self.suit))


class Deck(Cards):
    def __init__(self):
        self.deck = []
        self.suits = ["Clubs", "Spade", "Diamond", "Heart"]
        self.name = ["A", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
        self.value = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10]
        super().__init__(self.suits, self.name, self.value)

    def create_deck(self):

        for k in range(len(self.suits)):
            for x in range(len(self.name)):
                self.deck.append(Cards(self.suits[k], self.name[x], self.value[x]))

    # Mutates the deck by putting cards in random order
    def shuffle(self):
        for k in range(random.randint(1, 100)):
            for x in range(len(self.deck)):
                index1 = random.randint(0, 55)
                index2 = random.randint(0, 55)

                temp = self.deck[index1]
                self.deck[index1] = self.deck[index2]
                self.deck[index2] = temp

    def print_deck(self):
        for k in range(len(self.deck)):
            self.deck[k].print()


class Player():
    def __init__(self):
        self.cards = []


    def request(self,card):
        self.cards.append(card)


    def print_hand(self):
        for k in range(len(self.cards)):
            self.cards[k].print()

    def hand_value(self):
        total = 0
        for c in self.cards:
            total += c.value
        return total






def test():
    c1 = Cards("Spade", "J", 10)
    c1.print()
    print(c1.value)

    deck = Deck()
    count = 0
    mike = Player()

    deck.create_deck()
    deck.print_deck()
    print()
    deck.shuffle()
    deck.print_deck()
    print()
    mike.request(deck.deck[count])
    count += 1
    mike.request(deck.deck[count])
    count += 1
    print()
    mike.print_hand()
    print("DONE")

    print(mike.hand_value())



test()

