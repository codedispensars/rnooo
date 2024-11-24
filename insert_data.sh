#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
#INITIALIZE
($PSQL "TRUNCATE TABLE teams, games CASCADE")

#TEAMS
IsFirstLineSkipped=1
cat games.csv | while IFS="," read -a CSVArray; do
  if [[ $IsFirstLineSkipped == 1 ]]; then
    IsFirstLineSkipped=0

    continue
  fi

  #INSERT
  Country1="${CSVArray[3 - 1]}"
  Country2="${CSVArray[4 - 1]}"
  for Country in "$Country1" "$Country2"; do
    if [[ -z $($PSQL "SELECT team_id FROM teams WHERE name='$Country'") ]]; then
      $PSQL "INSERT INTO teams(name) VALUES ('$Country')"
    fi
  done
done

#GAMES
IsFirstLineSkipped=1
cat games.csv | while IFS="," read -a CSVArray; do
  if [[ $IsFirstLineSkipped == 1 ]]; then
    IsFirstLineSkipped=0

    continue
  fi

  #INSERT
  Year="${CSVArray[1 - 1]}"
  Round="${CSVArray[2 - 1]}"
  WinnerCountry="${CSVArray[3 - 1]}"
  OpponentCountry="${CSVArray[4 - 1]}"
  WinnerGoals="${CSVArray[5 - 1]}"
  OpponentGoals="${CSVArray[6 - 1]}"

  WinnerId=$($PSQL "SELECT team_id FROM teams WHERE name='$WinnerCountry'")
  OpponentId=$($PSQL "SELECT team_id FROM teams WHERE name='$OpponentCountry'")

  $PSQL "INSERT INTO \
          games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) \
         VALUES ($Year, '$Round', $WinnerId, $OpponentId, $WinnerGoals, $OpponentGoals)"
done
