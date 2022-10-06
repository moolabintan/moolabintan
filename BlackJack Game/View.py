import pygame
import Game
import Player
import sys
import Card

# Andrew Mills, Michael Olabintan
# done: This file contains functions that display all of the parts of our game onto the screen.
# init function declares instance variables to be used throughout the game
# display winner function displays who won each hand in a rectangle on the screen.
# rules function displays the rules page by blitting images and captions onto the screen when a button is pressed
# Main_menu function displays at the beginning of the game and serves as the center point in between the game,and rules
# page
# draw_everything function displays the game board and all of the captions and buttons needed to run the game.
# the function player cards and dealer cards puts the players and dealers cards onto the screen when they are called.


class View:
    def __init__(self, screen: pygame.Surface, game: Game):
        self.screen = screen
        self.game = game
        self.main_background = pygame.image.load("poker.jpg")
        self.game_background = pygame.image.load("felt.jpg")
        self.card_image_back = pygame.image.load("back of card.png")


        self.start_box = pygame.draw.rect(self.screen, (80, 80, 80), [250, 300, 150, 60])
        self.stand_box = pygame.draw.rect(self.screen, (80, 80, 80), [50, 300, 150, 60])
        self.hit_box = pygame.draw.rect(self.screen, (80, 80, 80), [450, 300, 150, 60])

    def display_winner(self):
        win_box = pygame.draw.rect(self.screen, (80, 80, 80), [60, 250, 550, 100])
        font1 = pygame.font.SysFont("Arial", 30)
        winner = font1.render(self.game.winner,True,pygame.Color("White"))
        self.screen.blit(winner,(250,275))
        pygame.display.update()


    def rules(self):
        font1 = pygame.font.SysFont("Arial", 30)
        font2 = pygame.font.SysFont("Arial",23)
        self.background_color = pygame.transform.scale(self.main_background, (650, 650))
        self.screen.blit(self.background_color, (0, 0))
        game_goal = font2.render("Goal of the Game is to have the sum of your cards equal 21", True, pygame.Color((255, 255, 255)))
        game_rules = font2.render("Press hit to recieve another card, press stand to move action to the Dealer",True, pygame.Color((255, 255, 255)))
        rules_2 = font2.render("If the sum of your cards is over 21 you lose!",True, pygame.Color((255, 255, 255)))
        back_to_main = font1.render("Press 3 to go Back to Main Menu",True, pygame.Color((255, 255, 255)))
        self.screen.blit(game_goal, (90, 100))
        self.screen.blit(game_rules, (35, 125))
        self.screen.blit(rules_2, (155, 150))
        self.screen.blit(back_to_main, (150, 175))
        pygame.display.update()

    def main_menu(self):
        font1 = pygame.font.SysFont("Arial", 30)
        self.background_color = pygame.transform.scale(self.main_background, (650, 650))
        self.screen.blit(self.background_color, (0, 0))
        press_space = font1.render("Press Space To Play", True, pygame.Color((255, 255, 255)))
        press_backspace = font1.render("Press Backspace To Quit", True, pygame.Color((255, 255, 255)))
        welcome = font1.render("Welcome to BlackJack!", True, pygame.Color((255, 255, 255)))
        press_2 = font1.render("Press 2 For Rules", True, pygame.Color((255, 255, 255)))
        self.screen.blit(press_space, (200, 180))
        self.screen.blit(press_backspace, (180, 140))
        self.screen.blit(welcome, (190, 100))
        self.screen.blit(press_2, (215, 220))
        pygame.display.update()

    def draw_everything(self):



        self.background_color = pygame.transform.scale(self.game_background,(650,650))
        self.screen.blit(self.background_color,(0,0))
        self.card_image_back = pygame.transform.scale(self.card_image_back, (75,100))
        font1 = pygame.font.SysFont("Arial", 30)
        caption1 = font1.render("Dealers Cards", True, pygame.Color((255, 255, 255)))
        caption2 = font1.render("Players Cards", True, pygame.Color((255, 255, 255)))
        caption3 = font1.render("Dealers Credit:"+ str(self.game.dealer_money), True, pygame.Color("White"))
        caption4 = font1.render("Players Credit:"+ str(self.game.player_money), True, pygame.Color("White"))
        caption5 = font1.render("Start", True, pygame.Color("White"))
        caption6 = font1.render("Stand", True, pygame.Color("White"))
        caption7 = font1.render("Hit", True, pygame.Color("White"))


        self.screen.blit(caption1,(50,160))
        self.screen.blit(caption2,(50,460))
        self.screen.blit(caption3,(450,160))
        self.screen.blit(caption4,(450,460))
        self.screen.blit(caption5, (300, 310))
        self.screen.blit(caption6, (115, 310))
        self.screen.blit(caption7, (510, 310))
        pygame.display.update()
        #draw the boxes for hit and stuff


    def draw_game(self):

        self.screen.blit(self.card_image_back, (300,290))
        pygame.display.update()




    def player_cards(self, cards):
        for k in range(len(cards)):
            card = cards[k].print() + ".png"
            self.screen.blit(pygame.transform.scale(pygame.image.load(card), (75, 100)) , (50 + (100 * k), 500))

        card = pygame.image.load(cards[len(cards) - 1].print() + ".png")
        self.screen.blit(pygame.transform.scale(card, (75, 100)), ((50 + (100 * (len(cards) - 1)), 500)))

        pygame.display.update()

    def dealer_cards(self, cards):
        for k in range(len(cards)):
            card = cards[k].print() + ".png"
            self.screen.blit(pygame.transform.scale(pygame.image.load(card), (75, 100)), (50 + (100 * k), 50))


        pygame.display.update()







