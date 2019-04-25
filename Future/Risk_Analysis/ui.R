#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  mainPanel(
    tabsetPanel(
      tabPanel("Plot",
               selectInput("input_project","Project Name",c("101","others")),
        fluidRow(column(width =6,plotlyOutput("Plot1")),
                 column(width =6,plotlyOutput("Plot2"))),
        fluidRow(column(width =6,plotlyOutput("Plot3")),
                 column(width =6,plotlyOutput("Plot4")))
                 )
        )
    )
  )
)

