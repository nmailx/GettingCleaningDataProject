## This R code takes data from the 2012 study performed by Reyes-Ortiz et al.
## on subjects wearing a smartphone (Samsung Galaxy S II) on the waist.
## The code is meant to tidy the data, and outputs a tidy data set that shows
## the mean average of each variable measured for each activity and each 
## test subject.

features.file <- "./UCI HAR Dataset/features.txt"
actlabel.file <- "./UCI HAR Dataset/activity_labels.txt"
train.file <- "./UCI HAR Dataset/train/X_train.txt"
test.file <- "./UCI HAR Dataset/test/X_test.txt"
train.label <- "./UCI HAR Dataset/train/Y_train.txt"
test.label <- "./UCI HAR Dataset/test/Y_test.txt"
trainsub.file <- "./UCI HAR Dataset/train/subject_train.txt"
testsub.file <- "./UCI HAR Dataset/test/subject_test.txt"

features <- read.table(features.file)
traindata <- read.table(train.file,col.names=features$V2)
testdata <- read.table(test.file,col.names=features$V2)
trainlabel <- read.table(train.label,col.names="Activity")
testlabel <- read.table(test.label,col.names="Activity")
activitylabel <- read.table(actlabel.file)
trainsub <- read.table(trainsub.file,col.names="Subject")
testsub <- read.table(testsub.file,col.names="Subject")

#Step 1 - Merge training and test data:
dataset <- rbind(traindata,testdata)

#Step 2 - Extract only measurements which are mean and standard deviation for each measurement
msfeatures <- features$V1[grepl('mean()',features$V2,fixed=T)|grepl('std()',features$V2,fixed=T)]
dataset <- dataset[,msfeatures]

#Step 3 - Name the activities in the data set
dataset <- cbind(rbind(trainlabel,testlabel),dataset)
for (activr in seq(1:length(dataset$Activity))){
    anum = as.integer(dataset$Activity[activr])
    dataset$Activity[activr] = as.character(activitylabel$V2[anum])
}

#Step 4 - Label the variables
#Done when reading the respective data files using col.names

#Step 5 - Create tidy data set with the average of each variable for each activity and each subject
dataset2 <- cbind(rbind(trainsub,testsub),dataset)
dataset2 <- dataset2[order(dataset2$Subject,dataset2$Activity),]

r2 = 1
d2 <- read.table(text="",col.names=c(names(dataset2)))

for (subj in unique(dataset2$Subject)){
    for (activ in unique(dataset2$Activity)){
        subtru = dataset2$Subject == subj
        acttru = dataset2$Activity == activ
        vmeans = colMeans(dataset2[subtru&acttru,3:68])
        d2[r2,1] <- subj
        d2[r2,2] <- activ
        d2[r2,3:68] <- unname(vmeans)
        r2 = r2 + 1
    }
}
    
write.table(d2,file="./UCI HAR Dataset/projtidydata.txt",row.names=F)
