## Coursera Course : Getting and Cleaning Data

### Peer Assessment by azrael42 26 April 2014

setwd("D:/Downloads/Coursera/Cleaning Data by Jeff Leek/Peer Assessment/")
rm(list=ls())

## Reminder: Definition of tidy data according to Lecture 3
# 1. Each variable should be in one column.
# 2. Each observation should be in one row.
# 3. One Table for each "kind" of variable
# 4. Multiple tables should be linked by "foreign keys".
# -- First row of each file contains variable names
# -- Human readable variables names
# -- One file per table

### Read raw data and immediately label columns appropriately
features <- read.table("UCI HAR Dataset/features.txt", as.is = TRUE)
names(features) <- c("featureId", "feature")

activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
names(activity_labels) <- c("activityId", "activity")

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
names(subject_train) <- c("subjectId")

subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
names(subject_test) <- c("subjectId")

y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
names(y_train) <- c("activityId")

y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
names(y_test) <- c("activityId")

suppressMessages( { library(LaF,quietly=TRUE); library(ffbase,quietly=TRUE); } )
## Packages LaF and ffbase are used since read.fwf is terribly slow
## Inspired by http://stackoverflow.com/questions/18720036/reading-big-data-with-fixed-width
X_train_laf <- laf_open_fwf("UCI HAR Dataset/train/X_train.txt",
                            column_widths = rep(16,561), column_types = rep("double",561) )
X_train_ffdf <- laf_to_ffdf(X_train_laf)
X_train <- as.data.frame(X_train_ffdf)
# features.txt actually contains the column names of X
names(X_train) <- c(features$feature)

X_test_laf <- laf_open_fwf("UCI HAR Dataset/test/X_test.txt",
                            column_widths = rep(16,561), column_types = rep("double",561) )
X_test_ffdf <- laf_to_ffdf(X_test_laf)
X_test <- as.data.frame(X_test_ffdf)
names(X_test) <- c(features$feature)

# Merge the training and the test sets to create one data set. 
X <- rbind(X_train, X_test)
y <- rbind(y_train, y_test)
subjects <- rbind(subject_train, subject_test)

# Clean up raw data from memory
rm(X_train,X_test,y_train,y_test,subject_train,subject_test)

#Extract only the measurements on the mean and standard deviation for each measurement. 
columnIds <- features[grepl("mean()|std()",features$feature),"featureId"]
X <- X[,columnIds]

## JOIN the separate data frames by cbind, ordering must be untouched!
data <- cbind( X, y, subjects )

# Appropriately label the data set with descriptive activity names. 
# Be careful, merge messes up ordering
data <- merge(data,activity_labels)
data$activityId <- NULL

# Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
# data table is fast and i am used to the syntax...
suppressMessages(require(data.table))
data <- data.table(data)
data2 <- data[,lapply(.SD, mean), by = list(subjectId, activity) ]

# write tidy data for upload
write.table(data2, "gettingAndCleaningData/tidyData.txt", row.names = FALSE)
