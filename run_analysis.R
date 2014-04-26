# download and unzip data
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile="./data.zip")
unzip("data.zip")

# load all data into R
x.train <- read.table("UCI HAR Dataset/train/X_train.txt", sep="")
y.train <- read.table("UCI HAR Dataset/train/y_train.txt")
subject.train <- read.table("UCI HAR Dataset/train/subject_train.txt")
features <- read.table("UCI HAR Dataset/features.txt")
activity <- read.table("UCI HAR Dataset/activity_labels.txt")

x.test <- read.table("UCI HAR Dataset/test/X_test.txt", sep="")
y.test <- read.table("UCI HAR Dataset/test/y_test.txt")
subject.test <- read.table("UCI HAR Dataset/test/subject_test.txt")

# set labels to identify measurements 
names(x.train)<-features[,2]
names(x.test)<-features[,2]
names(subject.train)<-c("subject")
names(subject.test)<-c("subject")
names(y.train)<-c("activity")
names(y.test)<-c("activity")
names(activity)<-c("num", "desc")

# Extract only the measurements on the mean and standard deviation for each measurement. 
x.train <- x.train[grep("mean|std",features$V2, value=TRUE)] 
x.test <- x.test[grep("mean|std",features$V2, value=TRUE)] 

# merge training and test set with the tables, identifying activities(descriptive names) and people 
full.train <- cbind(y.train,subject.train,x.train)
full.test <- cbind(y.test,subject.test,x.test)

# merget training set and test set
full.set <- rbind(full.train, full.test)

# add descriptive activity name
full.set$activityname <- "unset"
for (i in 1:6) {
  full.set$activityname[full.set$activity == i] <- gsub("_", " ", as.character(activity$desc[[i]]))
}  


# Create a second, independent tidy data set with the average of each variable for 
# each activity and each subject. 

# melt by activity and subject
library(reshape2)
melt.set <- melt(full.set, id=c("activity", "subject", "activityname"))

# take the average of each variable
means <- dcast(melt.set, formula = subject+activity+activityname ~ variable, mean)
write.table(means, "analysis_output.txt", sep=",",  row.names=F)