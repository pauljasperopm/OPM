library(shiny)
library(shinydashboard)
library(tidyverse)
library(lubridate)
library(DT)
library(shinyWidgets)

df <- read.csv("student_data.csv")

df <- df %>%
 mutate(dov = ymd(date_of_visit))

## Value1: Total Schools Covered
tot.school <- df %>% distinct(school) %>% nrow()

## Value2: Total Sudents Present
tot.present <- df %>% filter(student_present == "Present") %>% count()

## Value3: Total Enrolment
tot.enrolment <- df %>% filter(currently_enrolled != "No: Dropped out" & currently_enrolled != "") %>% nrow()

## Value4: Photo Mismatch  
photo.mismatch <- df %>% filter(verified_by_photo == "Mismatched photo") %>% count()

## Value5: Average enrolment by cohort C
avg.enrol <- df %>%
  filter(currently_enrolled != "No: Dropped out" & currently_enrolled != "") %>%
  group_by(school) %>%
  mutate(schl_enrol = n()) %>%
  group_by(cohort) %>%
  summarise(mean = mean(schl_enrol))

avg.enrol.C <- pull(subset(avg.enrol, cohort == "C")[,2])

## Value6: Average enrolment by cohort D
avg.enrol.D <- pull(subset(avg.enrol, cohort == "D")[,2])
  
############ ------------------------------------------ ############
shinyServer(function(input,output){
  
## Value1: Total Schools Covered ## 
  output$value1 <- renderValueBox({
    valueBox(
      formatC(tot.school, format="d", big.mark=','),
      paste('Total Schools :',tot.school),
      icon = icon("school",lib='font-awesome'),
      color = "purple") 
  })

## Value2: Total Sudents Present ##
  output$value2 <- renderValueBox({
    valueBox(
      formatC(tot.present$n[1], format="d", big.mark=','),
      paste('Total Present Students :',tot.present$n[1]),
      icon = icon("user-graduate",lib='font-awesome'),
      color = "green") 
  })

## Value3: Total Enrolment ##
  output$value3 <- renderValueBox({
    valueBox(
      formatC(tot.enrolment, format="d", big.mark=','),
      paste('Total Enrolled Students :',tot.enrolment),
      icon = icon("graduation-cap",lib='font-awesome'),
      color = "yellow")
  })
  
## Value4: Total Photo Mismatches ##  
  output$value4 <- renderValueBox({
    valueBox(
      formatC(photo.mismatch$n[1], format="d", big.mark=','),
      paste('Total Photo Mismatches :',photo.mismatch$n[1]),
      icon = icon("camera-retro",lib='font-awesome'),
      color = "purple")
  })

## Value5: Average enrolment in Cohort C ##
  output$value5 <- renderValueBox({
    valueBox(
      formatC(avg.enrol.C, big.mark=','),
      paste('Average Enrolment in Cohort C :', round(avg.enrol.C,2)),
      icon = icon("graduation-cap",lib='font-awesome'),
      color = "green")
  })

## Value6: Average enrolment in Cohort D ##
  output$value6 <- renderValueBox({
    valueBox(
      formatC(avg.enrol.D, big.mark=','),
      paste('Average Enrolment in Cohort D :', round(avg.enrol.D, 2)),
      icon = icon("address-card",lib='font-awesome'),
      color = "yellow")
  })
  
  output$histogram <- renderPlot({
    df %>%
      filter(district %in% input$dist) %>%
      group_by(cohort, dov) %>%
      mutate(schl.day = n_distinct(school)) %>%
      distinct(school, .keep_all = TRUE) %>%
      ggplot(aes(x = factor(dov), y = schl.day)) + geom_bar(position = "dodge", stat = "identity") + facet_wrap(~ cohort, nrow = 1) +
      geom_text(aes(label = schl.day), position=position_dodge(width=0.9), vjust=-0.25) +
      ylab("Schools") + xlab("Visit Date") +
      ggtitle("Number of schools by each day") +
      labs(subtitle = "Select district from top left to change graph") + 
      theme(plot.title = element_text(size = 20, face = "bold", hjust = 0.5),
            axis.text.x = element_text(angle = 90, hjust = 1),
            plot.subtitle=element_text(size=12, hjust=0.5, face="italic", color="black"))
  })
  
  output$mismatch <- renderPlot({
    
    df %>%
      filter(verified_by_photo != "") %>%
      group_by(district, verified_by_photo) %>%
      summarise(n = n()) %>%
      ggplot(aes(district, n, fill = verified_by_photo)) + 
      geom_bar(position = "dodge", stat = "identity") +
      geom_text(aes(label = n), position=position_dodge(width=0.9), vjust=-0.25) +
      ylab("Students") + xlab("District") +
      ggtitle("Students verified by photos") +
      theme(plot.title = element_text(size = 15, face = "bold", hjust = 0.5))
  })
  
  output$absent <- renderPlot({
    
    df %>%
      filter(student_present != "") %>%
      group_by(district, student_present) %>%
      summarise(n = n()) %>%
      ggplot(aes(district, n, fill = student_present)) + 
      geom_bar(position = "dodge", stat = "identity") +
      geom_text(aes(label = n), position=position_dodge(width=0.9), vjust=-0.25) +
      ylab("Students") + xlab("District") +
      ggtitle("Total Present Absent Students") +
      theme(plot.title = element_text(size = 15, face = "bold", hjust = 0.5))
  })
  
  output$etable <- DT::renderDataTable({
    df %>%
      group_by(enumerator) %>%
      summarise(
        Minimum  = min(time, na.rm = TRUE),
        Maxmimum = max(time, na.rm = TRUE),
        Mean     = round(mean(time, na.rm = TRUE), 2)
      )
  })
}
)
