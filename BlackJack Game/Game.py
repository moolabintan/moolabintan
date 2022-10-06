import pygame
import Player
import Deck
import Dealer
import View


# TODO: Put your names here (entire team)


class Game:
    #The game class handles all game events

    def __init__(self, screen: pygame.Surface):
        self.screen = screen
        self.deck = Deck.Deck()
        self.view = View.View(self.screen, self)
        self.player = Player.Player()
        self.dealer = Dealer.Dealer()
        self.top_card = 0
        self.player_money = 500
        self.dealer_money = 500

        self.game_started = False

        self.winner = ""

    # Begins the game. creates and shuffles the deck. takes an automatic bet from both player and dealer.
    def start_game(self):
        self.deck.create_deck()
        self.deck.shuffle()
        self.game_started = True
        self.player_money -= 50
        self.dealer_money -= 50

    #player is given the card "on top" of the deck
    def player_hit(self):
        self.player.request(self.top_card, self.deck.deck)
        self.top_card += 1

    #dealer is given the card "on top" of the deck
    def dealer_hit(self):
        self.dealer.request(self.top_card, self.deck.deck)
        self.top_card += 1

    #looks at the both player and dealer hand values and determines a winner from the rules of blackjack
    def choose_winner(self):
        if self.player.get_hand_value() <= 21 and self.dealer.get_hand_value() <= 21:
            if self.player.get_hand_value() > self.dealer.get_hand_value():
                self.winner = "Player Wins"
                self.player_money += 100

            elif self.player.get_hand_value() < self.dealer.get_hand_value():
                self.winner = "Dealer Wins"
                self.dealer_money += 100

            elif self.player.get_hand_value() == 21:
                self.winner = "Player Wins"
                self.player_money += 100

            elif self.dealer.get_hand_value() == 21:
                self.winner = "Dealer Wins"
                self.dealer_money += 100

            elif self.player.get_hand_value() == self.dealer.get_hand_value():
                self.winner = "It's A Push"
                self.player_money += 50
                self.dealer_money += 50

        elif self.player.get_hand_value() > 21 or self.dealer.get_hand_value() > 21:
            if self.player.get_hand_value() > 21:
                self.winner = "Dealer Wins"
                self.dealer_money += 100

            if self.dealer.get_hand_value() > 21:
                self.winner = "Player Wins"
                self.player_money += 100

    #begins a new game
    def restart_game(self):
        self.player.cards.clear()
        self.dealer.cards.clear()
        self.top_card = 0
        self.game_started = False
        self.view.draw_everything()

    def end_game(self, winner):
        self.winner = winner
