import time
import pygame
from Game import Game
from View import View
import math
import sys

# Andrew Mills, Michael Olabintan

# gets distance of each click from start, stand, and hit boxes in order to run the game.
def distance(point1, point2):
    point1_x = point1[0]
    point2_x = point2[0]
    point1_y = point1[1]
    point2_y = point2[1]
    return math.sqrt((point2_x - point1_x)**2 + (point2_y - point1_y)**2)


def main():

    pygame.init()
    screen = pygame.display.set_mode((650, 650))
    clock = pygame.time.Clock()
    game = Game(screen)
    viewer = View(screen, game)  # the View
    viewer.main_menu()

    pygame.mixer.init()
    pygame.mixer.music.load("music.mp3")
    pygame.mixer.music.play(-1, 0.0)

# the game loop handles all events in the game if a key is pressed as well as checks for a winner and displays the
# winner on the screen
    while True:
        clock.tick(10)
        for event in pygame.event.get():
            pressed_keys = pygame.key.get_pressed()
            if event.type == pygame.KEYDOWN and pressed_keys[pygame.K_BACKSPACE]:
                sys.exit()
            if event.type == pygame.KEYDOWN and  pressed_keys[pygame.K_SPACE]:
                viewer.draw_everything()
                pygame.display.update()
            if event.type == pygame.KEYDOWN and pressed_keys[pygame.K_2]:
                viewer.rules()
                pygame.display.update()
            if event.type == pygame.KEYDOWN and pressed_keys[pygame.K_3]:
                viewer.main_menu()
                pygame.display.update()
            if event.type == pygame.QUIT:
                sys.exit()

            if game.game_started == False:
                if event.type == pygame.MOUSEBUTTONDOWN:
                    click_pos = event.pos

                    distance_from_start_box = distance(click_pos, viewer.start_box.center)

                    if distance_from_start_box < 50:
                        game.start_game()
                        viewer.draw_game()
                        print("Game Started!")

            if event.type == pygame.MOUSEBUTTONDOWN:
                click_pos = event.pos

                distance_from_hit_box = distance(click_pos, viewer.hit_box.center)

                if distance_from_hit_box < 50:

                    game.player_hit()
                    game.player.print_hand()
                    print("player Hit")
                    viewer.player_cards(game.player.cards)

                distance_from_stand_box = distance(click_pos, viewer.stand_box.center)
                if distance_from_stand_box < 50:
                    if game.player.get_hand_value() > 21:
                        game.choose_winner()
                        viewer.display_winner()
                        time.sleep(2)
                        print("Dealer Wins")
                        game.restart_game()
                        break

                    if game.player.get_hand_value() == 21:
                        game.choose_winner()
                        viewer.display_winner()
                        time.sleep(2)
                        print("Player Wins")
                        game.restart_game()
                        break

                    while game.dealer.get_hand_value() < 17:
                        game.dealer_hit()
                        game.dealer.print_hand()
                        print("dealer hit")
                        viewer.dealer_cards(game.dealer.cards)
                        time.sleep(2)

                    print("Player Hand: ", str(game.player.get_hand_value()))
                    print("Dealer Hand: ", str(game.dealer.get_hand_value()))
                    game.choose_winner()
                    viewer.display_winner()
                    time.sleep(3)

                    if game.player_money == 0:
                        game.end_game("Dealer Wins The Game. You Lose!")
                        viewer.display_winner()
                        time.sleep(3)
                        sys.exit()

                    if game.dealer_money == 0:
                        game.end_game("Player Wins the Game. You Win!")
                        viewer.display_winner()
                        time.sleep(3)
                        sys.exit()

                    game.restart_game()


main()
