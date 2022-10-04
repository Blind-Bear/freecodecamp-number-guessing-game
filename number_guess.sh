#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Initial prompt
  echo "Enter your username:"

# Check username
  read USER_INPUT
  USER_FORMATTED=$(echo $USER_INPUT | sed -r 's/^ *| *$//g')

  # If found
    if ! [[ -z $($PSQL "SELECT * FROM users WHERE name = '$USER_FORMATTED'") ]]
    then
        
      # Get game info
      USERNAME=$($PSQL "SELECT name FROM users WHERE name = '$USER_FORMATTED'")
      GAMES_PLAYED=$($PSQL "SELECT count(*) FROM games INNER JOIN users USING(user_id) WHERE name = '$USER_FORMATTED'")
      BEST_GAME=$($PSQL "SELECT MIN(guess_count) FROM games INNER JOIN users USING(user_id) WHERE name = '$USER_FORMATTED'")

      # Display found user game info
      echo  "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    
    fi

  # If not found
    if [[ -z $($PSQL "SELECT * FROM users WHERE name = '$USER_FORMATTED'") ]]
    then
      echo "Welcome, $USER_FORMATTED! It looks like this is your first time here."

      # Insert user into database
      INSERT_NEW_USER=$($PSQL "INSERT INTO users(name) VALUES('$USER_FORMATTED')")

    fi

# Guess game
  # Game variables for loop
    SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USER_FORMATTED'")
    if [[ -z $GAMES_PLAYED ]]
    then
      GAMES_PLAYED=0
    fi
    
  echo "Guess the secret number between 1 and 1000:"

  DONE=2
  until [[ $DONE == 1 ]] ; do
  
  # Read guess
    read GUESS

  # Attempt counter start
    if [[ -z $ATTEMPT ]]
    then
      let "ATTEMPT = 1"
    fi

  # If invalid
    if ! [[ $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"

    else
  # If correct
      if [[ $GUESS == $SECRET_NUMBER ]]
      then
        FINAL_COUNT=$ATTEMPT
        let "NEW_GAME_ID = $GAMES_PLAYED + 1"

    # Insert game info
        INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(game_id, user_id, guess_count) VALUES($NEW_GAME_ID, $USER_ID, $FINAL_COUNT)")
        
    # Display message
        echo "You guessed it in $FINAL_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"


        DONE=1
      else
  # If guess is higher
        if [[ $GUESS -lt $SECRET_NUMBER ]]
        then
          echo "It's higher than that, guess again:"
          let "ATTEMPT = $ATTEMPT + 1"

        else
  # If guess is lower
        echo "It's lower than that, guess again:"
        let "ATTEMPT = $ATTEMPT + 1"
        fi
      fi
    fi
done
