library("caret")
library("e1071")
library("tree")
#install.packages("randomForest")
library("randomForest")
#install.packages("adabag")
library(adabag)

names(train)[2] <- "TF_2015"
names(train)[3]<- "TF_2016"
names(train)[4]<- "TF_2017"
names(test)[2] <- "TF_2015"
names(test)[3]<- "TF_2016"
names(test)[4]<- "TF_2017"

TF_tree <- tree::tree(as.factor(active)~.,train[,-1])
plot(TF_tree)
text(TF_tree)
prd1 <- predict(TF_tree,newdata =  train,type="class")
sum(diag(table(prd1,train$active)))/nrow(train)
prd.tst1 <- predict(TF_tree,test,type="class")
sum(diag(table(prd.tst1,test$active)))/nrow(test)


train$active <- as.factor(train$active)
TR_boosting <- boosting(active~.,data=train[,-1],boos=TRUE,mfinal=100)
predict.train.boost1 <- predict(TR_boosting,newdata=train)
importanceplot(TR_boosting)
TR_boosting$importance
predict.test.boost <- predict(TR_boosting,newdata=test)
predict.test.boost$confusion
error11 <- errorevol(TR_boosting,newdata=train)
plot.errorevol(error11)
sum(diag(predict.train.boost1$confusion))/nrow(train)
sum(diag(predict.test.boost$confusion))/nrow(test)

RF_truck <- train(active~., data=train[,-1],type="rf")
#RF_truck <- internet.rf

plot(RF_truck)
prd <- predict(RF_truck,newdata=train)
sum(diag(table(prd,train$active)))/nrow(train)
prd <- predict(RF_truck,newdata=test)
sum(diag(table(prd,test$active)))/nrow(test)

