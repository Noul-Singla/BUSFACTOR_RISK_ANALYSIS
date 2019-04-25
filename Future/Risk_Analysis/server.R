#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(RODBC)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)



cnnct_strng <- odbcConnect("DS6050")
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$Plot1 <- renderPlotly({
    
  
    TRUCK_FACTOR <- sqlQuery(cnnct_strng,paste0("select * from TRUCK_FACTOR where project = '",input$input_project,"';"),believeNRows=FALSE)
    
    
    plot_ly(data = TRUCK_FACTOR,x = ~commit_yr, y=~TF ,type = "scatter",mode="line") %>%
      layout(xaxis=list(tickformat='d'))
    
    
  })
    
  output$Plot2 <- renderPlotly({
    
  total_commits <- sqlQuery(cnnct_strng,paste0("select commit_yr,sum(total_commits) total_commits from file_commit where project ='",input$input_project,"'  group by commit_yr;"),believeNRows=FALSE)
    
  plot_ly(data = total_commits,x = ~commit_yr, y=~total_commits ,type = "scatter",mode="line") %>%
    layout(xaxis=list(tickformat='d'))
  
  
  
  })
  output$Plot3 <- renderPlotly({
      
    total_commits <- sqlQuery(cnnct_strng,paste0("select * from project_commits where project = '",input$input_project,"';"),believeNRows=FALSE)
    
    
    author_history <- sqlQuery(cnnct_strng,"select  * from author_history;",believeNRows=FALSE)
    
    
  })
  
  
  
  
})
