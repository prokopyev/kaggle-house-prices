# House prices Kaggle competition
# Start: 12-26-16
# MARS
# All factors must be numeric
library(caret)

train$SalePrice <- log(train$SalePrice + 200)
y <- train$SalePrice

X_train <- data.matrix(X_train)
X_test <- data.matrix(X_test)
# set up caret model training parameters
# model specific training parameter
CARET.TRAIN.CTRL <- trainControl(method="repeatedcv",
                                 number=10,
                                 repeats=5,
                                 verboseIter=FALSE)

set.seed(99)

marsGrid <- expand.grid(.degree = seq(5,10),
                        .nprune = (4:20) * 2)

mars.caret <- train(x=X_train, y=y,
                        method="earth",
                        trControl=CARET.TRAIN.CTRL, 
                        maximize=FALSE,
                        tuneGrid = marsGrid,
                        metric="RMSE") 

print(mars.caret)
plot(mars.caret)
mean(mars.caret$resample$RMSE)

resultsTableExport <- cbind(resultsTable,Model="mars",lowestRmse=mean(mars.caret$resample$RMSE))
currentDateTime <- strftime(Sys.time(), "%Y %m %d %H %M %S") 

csvFileName <- paste("C:/Users/kruegkj/Documents/GitHub/kaggle-house-prices/",
                     currentDateTime,".csv",sep="") 
write.csv(resultsTableExport, file=csvFileName) 
rm(resultsTableExport)

# make create submission file
preds <- exp(predict(mars.caret,newdata=X_test)) - 200

# construct data frame for solution
submission = read.csv("Data/sample_submission.csv", colClasses = c("integer", "numeric"))
submission$SalePrice = preds
write.csv(submission, "Submissions/caret-mars-v1-1-22-17.csv", row.names = FALSE)
