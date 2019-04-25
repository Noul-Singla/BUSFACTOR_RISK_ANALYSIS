library(RODBC)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(corrplot)


cnnct_strng <- odbcConnect("DS6050")

TRUCK_FACTOR <- sqlQuery(cnnct_strng,"select * from TRUCK_FACTOR;",believeNRows=FALSE)
summary(TRUCK_FACTOR)
TF_SPREAD <- spread(TRUCK_FACTOR,key = "commit_yr",value = "TF")
TF_SPREAD[is.na(TF_SPREAD)] <- 0
TF_SPREAD
TF_SPREAD[TF_SPREAD$`2015`>2,]

TRUCK_FACTOR %>%
  filter(project =="101") %>%
plot_ly(x = ~commit_yr, y=~TF ,type = "scatter",mode="line")


total_commits <- sqlQuery(cnnct_strng,"select * from project_commits;",believeNRows=FALSE)

author_history <- sqlQuery(cnnct_strng,"select  * from author_history;",believeNRows=FALSE)

sum(total_commits$project_commits>10)


total_commits %>%
  mutate(Commit_group = cut_number(project_commits,20)) %>%
  ggplot(aes(Commit_group)) +geom_bar() + theme(axis.text.x = element_text(angle=50))



TF_SPREAD <- TF_SPREAD %>%
                mutate(cat = ifelse(`2015`==`2016`&`2015`==`2017`&`2015`==`2018`,"same","change"))

TF_SPREAD <- TF_SPREAD %>%
      mutate(beginning_2015 = ifelse(`2015`>0,1,0)) %>%
      mutate(beginning_2016 = ifelse(`2015`==0 & `2016`>0,1,0))


sum(TF_SPREAD$beginning_2015)
sum(TF_SPREAD$beginning_2016)

project_filter <- TF_SPREAD %>%
                  filter(beginning_2015 ==1 | beginning_2016 ==1) %>%
                    select(project)



project_filter <- project_filter[,1]

TF_SPREAD_fitler <- TF_SPREAD %>%
  filter(beginning_2015 ==1 | beginning_2016 ==1) 

#project after fiterations
nrow(TF_SPREAD_fitler)
#7465

TF_SPREAD_fitler%>%
  mutate(beginning_2015 =as.factor(beginning_2015))%>%
ggplot(aes(cat))+geom_bar(aes(fill=beginning_2015),position="dodge")

TF_SPREAD_fitler%>%
  mutate(beginning_2015 =as.factor(beginning_2015))%>%
  ggplot(aes(beginning_2015))+geom_bar()


TRUCK_FACTOR %>%
  filter(project %in% project_filter & commit_yr=="2015") %>%
#  mutate(group = cut_interval(TF,13)) %>%
  ggplot(aes(TF)) +geom_bar() + theme(axis.text.x = element_text(angle=50))


TF_SPREAD_fitler <- TF_SPREAD_fitler %>%
                      mutate(active = ifelse(`2018`==0,0,1))

head(TF_SPREAD_fitler)
head(total_commits)

TF_merged <- merge(TF_SPREAD_fitler,total_commits)
head(TF_merged)

ggplot(TF_SPREAD_fitler,aes(active))+geom_bar()


author_history %>%
  filter(project =="101")

author_history_feature_engineered <- author_history %>%
                  mutate(author_15_16 = abs(name_2015-name_2016)) %>%
                  mutate(author_16_17 = abs(name_2016-name_2017)) %>%
                  mutate(author_17_18 = abs(name_2017-name_2018)) %>%
                  select(project,author_15_16,author_16_17,author_17_18) %>%
                  group_by(project) %>%
                  summarise(author_15_16 = sum(author_15_16),author_16_17=sum(author_16_17),author_17_18=sum(author_17_18))%>%
                  ungroup() 

TF_feature_merged <- TF_merged %>%
                      mutate(change_15_16 = `2016`-`2015`) %>%
                      mutate(change_16_17 = `2017`-`2016`) %>%
                      mutate(change_17_18 = `2018`-`2017`) %>%
                      mutate(change_15_18 = `2018`-`2015`) %>%
                      mutate(change_16_18 = `2018`-`2016`) %>%
                      mutate(change_15_17 = `2017`-`2015`) %>%
                      left_join(author_history_feature_engineered,by="project") 
TF_feature_merged$cat  <- as.factor(TF_feature_merged$cat)

correlations <- cor(TF_feature_merged[,c(-1,-6)])
corrplot(correlations, method="circle")

sample_id <- sample(1:nrow(TF_feature_merged),0.8*nrow(TF_feature_merged))
length(sample_id)
head(TF_feature_merged)
train <- TF_feature_merged[sample_id,c(-5,-6,-13,-14,-15,-19)]
test <- TF_feature_merged[-sample_id,c(-5,-6,-13,-14,-15,-19)]

LM_FUNCTION <- function(train,test){
  lm_fit <- glm(active~.,data=train,family = binomial)
  temp <- predict(lm_fit,type="response")
  temp2 <- ifelse(temp>.5,1,0)
  train_accuracy <- sum(diag(table(train$active,temp2)))/nrow(train)
  
  temp_test <- predict(lm_fit,newdata=test,type="response")
  temp2_test <- ifelse(temp_test>.5,1,0)
  aa <- table(test$active,temp2_test)
  test_accuracy <- sum(diag(aa))/nrow(test)
  
  return(c(train_accuracy,test_accuracy))
}


#fit with all variables
round(100*LM_FUNCTION(train[,-1],test[,-1]),2)

#fit only with TF per year for last 3 years
round(100*LM_FUNCTION(train[,c(2,3,4,7,8)],test[,c(2,3,4,7,8)]),2)

lm_fit <- glm(active~.,data=train[,-1],family = binomial)
lm_fit$coefficients
summary(lm_fit)


ggplot(TF_feature_merged,aes(cat))+geom_bar()

ggplot(TF_feature_merged,aes(change_15_16))+geom_bar(aes(fill=as.factor(active)),position="dodge")
ggplot(TF_feature_merged,aes(author_15_16))+geom_bar(aes(fill=as.factor(active)),position="dodge")




table(TF_feature_merged[TF_feature_merged$`2017`==0,c("2017","2018")])
table(TF_feature_merged[TF_feature_merged$`2017`>0,c("2017","2018")])
table(TF_feature_merged$active)

