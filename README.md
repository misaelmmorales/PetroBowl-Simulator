# PetroBowl Simulator

This is an R/Shiny application design to emulate the SPE PetroBowl competition.

### GAME RULES ###
- Each game consists of N questions and T minutes - normally, N=40 and T=8 minutes.
- The fastest player to answer for each team must provide their answer, and if correct then that team earns 10 points. If incorrect, they lose 5 points and the turn goes to the other team, with the same scoring criteria.
- Each player has 15 seconds to answer their question after buzzing in, or skip to the next question without buzzing (once you buzz, whatever answer you provide - even if blank - will be counted toward the scoring).

### USAGE ###
- **Left panel**: user-controlled game details, including team, total number of questions, total game time, time per question, and a _start game_ validation.
- **Main Page**: After validation, questions are displayed here, along with buttons for buzzing in, submitting answer, and moving to the next question. Timers show game time and question time remaining, as well as current question counter.
- **Results tab**: displays all the questions for which the user submitted an answer, along with the time taken to submit.
- **Solution Key tab**: displays the correct answer for each of the questions in the game. This appears after total game time is over.
![alt_text](https://github.com/misaelmmorales/PetroBowl-Simulator/blob/main/images/right_side.png)
*Main Page panel preview*


### QUESTION BANK ###
- Please use your own question-answer set for this simulator. The preferred format is MS Excel. A sample file (sample_Qbank.xlsx - https://github.com/misaelmmorales/PetroBowl-Simulator/blob/main/sample_Qbank.xlsx) is uploaded to demonstrate the format/headers of the .xlsx document
![alt text](https://github.com/misaelmmorales/PetroBowl-Simulator/blob/main/images/sample_Qbank.png)

### SPE ###
- Check out https://www.spe.org/en/students/petrobowl/ for more information regarding PetroBowl!!!
