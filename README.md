## README for 'run_analysis.R'
### Dataset

The dataset used in this R file is taken from the 2012 study performed by Reyes-Ortiz et al. on subjects wearing a smartphone (Samsung Galaxy S II) on the waist. The code is meant to tidy the data, and outputs a tidy data set that shows the mean average of each variable measured for each activity and each test subject.

### Data files
The entire raw dataset is saved in the folder 'UCI HAR Dataset'. Within this folder, there are 2 subfolders: 'training' and 'test'. 2 files from the main folder are read: 'features.txt' and 'activity_labels.txt'. The data, activity label and subject identity files from the 'training' and 'test' subfolders are also read, making a total of 8 data files read in this R code.

The names of the features measured in the study are read from 'features.txt'. The features' names are then assigned as column names when reading the training and test data.

### Step 1: Merge training and test data
The following code
```
dataset <- rbind(traindata,testdata)
```
is used to merge the training and data sets into one data frame

### Step 2: Extract only measurements which are mean and standard deviation for each measurement
In the following code
```
msfeatures <- features$V1[grepl('mean()',features$V2)|grepl('std()',features$V2)]
```
grepl(pattern,text) returns TRUE if 'pattern' is a substring of the string 'text'. Therefore, msfeatures is a logic vector containing the features (or variables) that are means or standard deviations. The next line of code 
```
dataset <- dataset[,msfeatures]
```
subsets the columns corresponding to the features that are means or standard deviations.

### Step 3: Name the activities in the data set
First, we combine the corresponding activities performed in each observation with our dataset:
```
dataset <- cbind(rbind(trainlabel,testlabel),dataset)
```
Next, we use a for loop to convert the activity label into the string corresponding to the actual activity name
```
for (activr in seq(1:length(dataset$Activity))){
    anum = as.integer(dataset$Activity[activr])
    dataset$Activity[activr] = as.character(activitylabel$V2[anum])
}
```
Here, 'activr' corresponds to the row number in 'dataset'. 'anum' corresponds to the activity label of the row. The last line in the for loop replaces the activity label with the actual activity name, determined by subsetting the 'activitylabel' dataframe using 'anum'. We use as.integer to force anum into an integer, since dataset$Activity will become a string once the first activity name has been entered.

### Step 4: Label the variables
This was done when reading the respective data files, by using col.names=features$V2 for both the training and test data sets
```
traindata <- read.table(train.file,col.names=features$V2)
testdata <- read.table(test.file,col.names=features$V2)
```

### Step 5: Create tidy data set with the average of each variable for each activity and each subject
The last set involves creating a duplicate, tidy data set that contains the mean of each variable measured for each subject and activity. In other words, we are taking the mean of each mean and standard variable of all features, for each subject and each activity.

We first duplicate the dataset and arrange it according to subject, then activity in ascending order
```
dataset2 <- cbind(rbind(trainsub,testsub),dataset)
dataset2 <- dataset2[order(dataset2$Subject,dataset2$Activity),]
```
'd2', an empty data frame is initialized, with column names corresponding to 'dataset' and 'dataset2'. 'r2', the first row number of 'd2' is also initialized at 1. 'd2' will be used to store the tidy data.

A for loop is used to iterate through all subjects, and a nested for loop will iterate through all activities. This allows us to perform the calculations for mean for each subject and activity.
```
subtru = dataset2$Subject == subj
acttru = dataset2$Activity == activ
vmeans = colMeans(dataset2[subtru&acttru,3:81])
```
'subtru' and 'acttru' are logic vectors that represent the rows where the subject is the one in the current iteration ('subj') and the activity is the one in the current iteration ('activ'). 'vmeans' then stores the mean of each column from columns 3 to 81, which correspond to the 79 variables from the 'dataset' data frame previously.

In the next block of code embedded in the for loop:
```
d2[r2,1] <- subj
d2[r2,2] <- activ
d2[r2,3:81] <- unname(vmeans)
r2 = r2 + 1
```
We append the subject and activity of the current iteration, as well as 'vmeans', to 'd2'. 'r2' then increases by 1 which signifies that we will append to the next row after we calculate 'vmeans' for the next subject and activity.

Finally, we write the tidy data to the text file 'projtidydata.txt' in the 'UCI HAR Dataset' folder, with row.names set to FALSE.
