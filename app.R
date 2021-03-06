################################################################################
################################ PetroBowl Simulator
################################ Designed by Misael M. Morales 
################################ 2020-2021
################################ https://github.com/misaelmmorales

#### Description ####
# this is a Shiny script to perform interactive PetroBowl practice games over
# multiple players. Games are set up to have N questions or T minutes,
# (by default, {N,T}={20,4}) and the player/team with the most points wins.

#### install/load the necessary packages ####
library(shiny)     # framework for Shiny app
library(shinyjs)   # to hold interactive JS Shiny
library(readxl)    # to import MS Excel files
library(tictoc)    # to handle times & timers
library(dplyr)     # to handle dataframes
library(lubridate) # to manage dates & times
library(rsconnect) # to deploy on the web

#### read the Excel Question banks ####
wd <- getwd()                                 #set current folder as working dir
xl_path <- "sample_Qbank.xlsx"                #define the question bank name
df_path <- paste(wd, xl_path, sep="/")        #create a variable for full path
df <- read_excel(path=df_path, sheet=1)       #read excel into a df

#### define the UI page ####
ui <- fluidPage(
  useShinyjs(),     #Shiny JavaScript package for several functions/capabilities
  sidebarLayout(
    sidebarPanel(
      h2("PetroBowl Game Simulator"),
      h3(''),
      textInput("user_name", label="Enter player alias"),
      h3(''),
      radioButtons("n_team", label="Select team number", choices=c("A","B")),
      h3(''),
      numericInput("gamelength", label="Total number of questions", value=25, min=5, max=60, step=1),
      h3(''),
      numericInput("gametime", label="Total game time (minutes)", value=4, min=1, max=10, step=1),
      h3(''),
      numericInput("seconds", label="Question timer (seconds)", value=15, min=1, max=60, step=1),
      h3(''),
      passwordInput("startgame", label="Game Start Validation - (type: 'start')"),
      h3(''),
      hr(style="border-top: 1px solid #000000;"),
      h5('2020-2021 PetroBowl'),
      h5('Society of Petroleum Engineers'),
      hr(style="border-top: 1px solid #000000;"),
      h5('Designed by: Misael M. Morales'),
      h5('https://github.com/misaelmmorales'),
      h5('updated: 03.2021'),
      h3(''),
    ),
    mainPanel(
      h4(textOutput("current_date")),
      h4(textOutput("game_time")),
      tabsetPanel(type="tabs",
                  tabPanel("Main Page",
                           h3(''),
                           textOutput("Q_header"),
                           tableOutput("question"),
                           h3(''),
                           #button to buzz-in for the given question
                           actionButton("buzz_button", label="Buzz In", class="btn-success"),
                           hr(style="border-top: 1px solid #000000;"),
                           disabled(textInput("answer", label="your answer:")),
                           #button to submit answer
                           div(style="display: inline-block", 
                               actionButton("submit_button", label="Submit", style="color: #FFFFFF; 
                              background-color: #990000; 
                              border-color:     #000000")),
                           div(style="display: inline-block", textOutput("timeleft")),
                           h3(''),
                           hr(style="border-top: 0.5px solid #000000;"),
                           #button the go to the next question in the game
                           div(style="display:inline-block",
                               actionButton("next_button", label="Next Question", class="btn-warning", icon("Submit"))),
                           div(style="display:inline-block", h5('Question answered or timer expired. Next.'))
                  ),
                  # New tab to show answers and times for questions submitted
                  tabPanel("Results",
                           h5('** Your answers will de displayed here'),
                           tableOutput("results_table")),
                  # New tab to show correct answers to each question
                  tabPanel("Solution Key",
                           h5('** Solutions will appear after game ends'),
                           tableOutput("sol_key"))
      )))) 

#### define the Server page ####
server <- function(input, output, session){
  
  isolate({qtime <- input$seconds})           #isolate current game timing
  isolate({total_gametime <- input$gametime}) #isolate total game time
  isolate({length <- input$gamelength})       #isolate number of game questions
  isolate({question_sample <- sample(df$N, length)}) #isolate question list
  
  #Header for time/date in the game
  output$current_date <- renderText({
    invalidateLater(1000, session)
    paste("Today's Date is: ", Sys.Date())})
  
  #Total Game time left
  output$game_time <- renderText({
    invalidateLater(1000, session)
    paste("Game Timer Remaining: ", 1)})
  
  #Reactive/observe for clicking of the buzz-in button
  observeEvent(input$buzz_button, {toggle('input')})
  
  #Reactive values for timers (total & question)
  timer <- reactiveVal(qtime)
  timer_total <- reactiveVal(60*total_gametime)
  active <- active_total <- reactiveVal(FALSE)
  output$timeleft <- renderText({paste("Time Remaining: ", seconds_to_period(timer()))})
  output$game_time <- renderText({paste("Game Time Remaining: ", seconds_to_period(timer_total()))})
  
  #Reactive value for question counter (based on button for next question)
  counter <- reactiveValues(countervalue=0)
  observeEvent(input$next_button,{
  counter$countervalue <- counter$countervalue+1})
  
  #Display questions
  output$Q_header <- renderText({paste("Question #: ", counter$countervalue+1)})
  output$question <- renderTable({
    validate(need(
      input$startgame=="start",
      "Please type 'start' in the 'Game Start Validation' section to begin"))
    df$Question[question_sample[counter$countervalue+1]]})
  
  ## second Tab (Results Summary)
  values <- reactiveValues()
  values$df <- data.frame("Number"=NA, "Team"=NA, "Player"=NA, "Time_elapsed"=NA, "Answer"=NA, "Question"=NA)
  newEntry <- observe({
    if(input$submit_button>0){
      newLine <- isolate(c(counter$countervalue+1, input$n_team, 
                           input$user_name, qtime-seconds_to_period(timer()), input$answer, 
                           df$Question[question_sample[counter$countervalue+1]]))
      isolate(values$df <- rbind(values$df, newLine))
    }})
  output$results_table <- renderTable(values$df, colnames=TRUE)
  
  ## third tab (Answer Key)
  sol <- data.frame("Number"=as.integer(question_sample), 
                    "True Number"=as.integer(seq_along(question_sample)),
                    "Question"=df$Question[question_sample], 
                    "Answer"=df$Answer[question_sample])
  
  observe({
    if(timer_total()==0){
      output$sol_key <- renderTable(sol)}})
  
  # Other server functions
  observe({
    invalidateLater(1000, session)
    isolate({
      if(active()){
        timer(timer()-1) #timer countdown (resolution=seconds)
        if(timer()<1){
          active(FALSE)
          showModal(modalDialog(title="Time Expired!"))}}
      if(input$startgame=="start" & timer_total()>=0){
        timer_total(timer_total()-1)
        if(timer_total()==0){
          showModal(modalDialog(title="GAME OVER!"))}
      }})})
  
  #Observe action events for buttons (buzzer, submissions, next)
  observeEvent(input$buzz_button, c({active(TRUE)},{active_total(TRUE)},{enable("answer")}))
  observeEvent(input$submit_button, c({active(FALSE)},{disable("answer")}))
  observeEvent(input$next_button, c({timer(input$seconds)}, {updateTextInput(session,"answer",value="")}))
}
################################# Run Shiny #################################### 
shinyApp(ui=ui, server=server)
