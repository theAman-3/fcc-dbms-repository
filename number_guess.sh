#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only --no-align -c"

RANDOM_NUMBER=$(( $RANDOM % 1000 + 1))

NUMBER_OF_GUESSES=0

GAME_PLAYING () {
  if [[ $1 ]]
  then
    echo -e "$1"
  else
    echo -e "\nGuess the secret number between 1 and 1000:"
  fi

  # reading users guess number
  read USERS_GUESS_NUMBER
  ((NUMBER_OF_GUESS++))

  if [[ $USERS_GUESS_NUMBER =~ ^[0-9]+$ ]]
  then
    if [[ $USERS_GUESS_NUMBER == $RANDOM_NUMBER ]]
    then
      UPDATE_IN_DATABASE=$($PSQL "INSERT INTO games(user_id, guess) VALUES($USER_ID, $NUMBER_OF_GUESS)")

      echo "You guessed it in $NUMBER_OF_GUESS tries. The secret number was $RANDOM_NUMBER. Nice job!"
    
    elif [[ $USERS_GUESS_NUMBER -gt $RANDOM_NUMBER ]]
    then
      GAME_PLAYING "It's lower than that, guess again:$RANDOM_NUMBER $NUMBER_OF_GUESS"

    else
      GAME_PLAYING "It's higher than that, guess again:$RANDOM_NUMBER $NUMBER_OF_GUESS"
    fi
  else
   # when user doesn't guesses the integer
    GAME_PLAYING "That is not an integer, guess again:$RANDOM_NUMBER $NUMBER_OF_GUESS"
  fi
}

MAIN_MENU() {
  echo "Enter your username:"
  read USERNAME

  USER=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")
  if [[ -z $USER ]]
  then
    INSERT_NEW_USER=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE user_id=$USER_ID")
    BEST_GAME=$($PSQL "SELECT MIN(guess) FROM games INNER JOIN users USING(user_id) WHERE user_id=$USER_ID")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE user_id=$USER_ID")
    BEST_GAME=$($PSQL "SELECT MIN(guess) FROM games INNER JOIN users USING(user_id) WHERE user_id=$USER_ID")
    echo "Welcome back, $USERNAME! You have played $(($GAMES_PLAYED)) games, and your best game took $(($BEST_GAME)) guesses."
  fi


  GAME_PLAYING
}

MAIN_MENU
