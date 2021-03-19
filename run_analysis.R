
##First, download file
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/UCI_HAR.zip", method="curl")

##Then unzip
unzip(zipfile="./data/UCI_HAR.zip",exdir="./data")

##Read files
##Activity files
activityTest <- read.table("./data/UCI HAR Dataset/test/y_test.txt", header = FALSE)
activityTrain <- read.table(file.path("./data/UCI HAR Dataset//train/y_train.txt"), header = FALSE)

##Subject files
subjectTest <- read.table(file.path("./data/UCI HAR Dataset/test/subject_test.txt"), header = FALSE)
subjectTrain <- read.table(file.path("./data/UCI HAR Dataset/train/subject_train.txt"), header = FALSE)

##Feature files
featureTest <- read.table(file.path("./data/UCI HAR Dataset/test/X_test.txt"), header = FALSE)
featureTrain <- read.table(file.path("./data/UCI HAR Dataset/train/X_train.txt"), header = FALSE)
featureNames <- read.table(file.path("./data/UCI HAR Dataset/features.txt"), header = FALSE)


##Merge the training and the test sets to create one data set.
##Join the rows
subjectWhole <- rbind(subjectTest,subjectTrain)
activityWhole <- rbind(activityTest,activityTrain)
featureWhole <- rbind(featureTest,featureTrain)

##Name Variables
names(subjectWhole) <- c("subject")
names(activityWhole) <- c("activity")
names(featureWhole) <- featureNames$V2

##Join the columns
dataFull <- cbind(subjectWhole,activityWhole,featureWhole)


##Extract only the measurements on the mean and standard deviation for 
##each measurement. 
library(dplyr)
dataFiltered <- select(dataFull, subject, activity, contains("mean"),
                       contains("std"))

##Use descriptive activity names to name the activities in the 
##data set
dataFiltered$activity <- gsub("1","walking",dataFiltered$activity)
dataFiltered$activity <- gsub("2","walking_upstairs",dataFiltered$activity)
dataFiltered$activity <- gsub("3","walking_downstairs",dataFiltered$activity)
dataFiltered$activity <- gsub("4","sitting",dataFiltered$activity)
dataFiltered$activity <- gsub("5","standing",dataFiltered$activity)
dataFiltered$activity <- gsub("6","laying",dataFiltered$activity)


##Appropriately labels the data set with descriptive variable names.
names(dataFiltered) <- gsub("^t","time",names(dataFiltered))
names(dataFiltered) <- gsub("tBody","timeBody",names(dataFiltered))
names(dataFiltered) <- gsub("^f","frequency",names(dataFiltered))
names(dataFiltered) <- gsub("Acc","Accelerometer",names(dataFiltered))
names(dataFiltered) <- gsub("Gyro","Gyroscope",names(dataFiltered))
names(dataFiltered) <- gsub("Mag","Magnitude",names(dataFiltered))
names(dataFiltered) <- gsub("BodyBody","Body",names(dataFiltered))
names(dataFiltered) <- gsub("mean","Mean",names(dataFiltered))
names(dataFiltered) <- gsub("std","Std",names(dataFiltered))
names(dataFiltered) <- gsub("gravity","Gravity",names(dataFiltered))


##From the data set in step 4, create a second, independent tidy 
##data set with the average of each variable for each activity 
##and each subject.
tidyData <- group_by(dataFiltered, subject, activity)
tidyData <- aggregate(. ~subject + activity, dataFiltered, mean)
tidyData <- arrange(tidyData,subject,activity)
write.table(tidyData, file = "tidydata.txt",row.name=FALSE)
