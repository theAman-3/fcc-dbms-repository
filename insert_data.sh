#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then
    # get winner_id 
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # if not found
    if [[ -z $WINNER_ID ]]
    then
    # get new winner_id
      INSERT_WINNER_ID=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_ID == 'INSERT 0 1' ]]
      then
        echo Inserted new team, $WINNER
      fi
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

# GETTING OPPONENT'S ID
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # if not found
    if [[ -z $OPPONENT_ID ]]
    then
    # get new winner_id
      INSERT_OPPONENT_ID=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_ID == 'INSERT 0 1' ]]
      then
        echo Inserted new team, $OPPONENT
      fi
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

# GETTING GAME'S ID
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE ( winner_id=$WINNER_ID AND opponent_id=$OPPONENT_ID ) AND round='$ROUND'")
    if [[ -z $GAME_ID ]]
    then
      INSERT_GAME_ID=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
      if [[ $INSERT_GAME_ID == 'INSERT 0 1' ]]
      then
        echo Inserted a game data, $YEAR, $ROUND, $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS 
      fi
      #GAME_ID=$($PSQL "SELECT game_id FROM games WHERE ( winner_id=$WINNER_ID AND opponent_id=$OPPONENT_ID ) AND round=$ROUND")
    
    else
      echo Already exists at game_id = $GAME_ID
    fi

  fi
done
