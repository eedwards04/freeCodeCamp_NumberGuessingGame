#!/bin/bash
# Initial commit

# feat: add database connection
PSQL="psql --username=freecodecamp --dbname=number-guess -t --no-align -c"

# feat: add user login logic
echo -e "\nEnter your username: "
read USERNAME

USER_DATA=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")

if [[ -z $USER_DATA  ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# feat: add guessing loop
GUESS_COUNT=1
RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))
echo -e "\nGuess the secret number between 1 and 1000:"
read USER_GUESS

while [[ $USER_GUESS -ne $RANDOM_NUMBER ]]
do
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $USER_GUESS -gt $RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  read USER_GUESS
  (( GUESS_COUNT++  ))
done

# feat: add win condition
echo -e "\nYou guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"

#feat: add to database
UPDATE_GAMES=$($PSQL "UPDATE users SET games_played=games_played + 1 WHERE username='$USERNAME'")

if [[ -z $BEST_GAME || $GUESS_COUNT -lt $BEST_GAME ]]
then
  UPDATE_BEST=$($PSQL "UPDATE users SET best_game = $GUESS_COUNT WHERE username='$USERNAME'")
fi
