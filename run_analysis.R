##STEP: GET DATA

if(!file.exists("./data")){dir.create("./data")}
fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/Dataset.zip")

unzip(zipfile = "./data/Dataset.zip", exdir = "./data")

#STEP 1: Load And Merge Datasets

#training data
x_train<- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train<- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train<-read.table("./data/UCI HAR Dataset/train/subject_train.txt")

#testing data
x_test<-read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test<-read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test<-read.table("./data/UCI HAR Dataset/test/subject_test.txt")

#Getting features
features<- read.table("./data/UCI HAR Dataset/features.txt")

#Getting Activity Labels
activity_labels<-read.table('./data/UCI HAR Dataset/activity_labels.txt')

#adding Feature Labels to columns
colnames(x_test)<-features[,2]
colnames(x_train)<-features[,2]
colnames(subject_train)<-"subject_id"
colnames(subject_test)<-'subject_id'

#add colnames to dependant variable
colnames(y_test)<-"activity_id"
colnames(y_train)<-"activity_id"

colnames(activity_labels)<-c("activity_id", 'activity_type')

#Merge Data

merged_train<-cbind(y_train, subject_train, x_train)
merged_test<-cbind(y_test,subject_test, x_test)
merged_data<-rbind(merged_train, merged_test)

##STEP 2 EXTRACT MEAN AND STD FOR EACH MEASUREMENT

#extract Colnames
colnames<-colnames(merged_data)

#create boolean vector to subset columns for mean and std
col_std_mean<-(grepl("activity_id", colnames)|
                grepl("subject_id" , colnames)|
                grepl("mean.." , colnames)|
                grepl("std.." , colnames)
               )

#subset the merged_data to get only std, mean and id columns
mean_std_data<-merged_data[, col_std_mean]


##STEP 3: USE DESCRIPTIVE NAMES TO NAME THE ACTIVITIES 

complete_dataset<- merge(mean_std_data, activity_labels,
                         by='activity_id',
                         all.x=TRUE)

##STEP 4: APPROPRIATELY LABEL THE DATASET WITH DESCRIPTIVE VARIABLE NAMES 

##(DONE IN PREVIOUS STEPS)

#STEP 5: CREATE A SECOND INDEPENDANT TIDY DATA SET WITH AVERAGE OF EACH VARIABLE
library(dplyr)
finaldataset <- complete_dataset %>%
        group_by(subject_id, activity_id) %>%
        summarise_all(funs(mean))

#save as new .txt file
write.table(finaldataset, "finaldataset.txt", row.name=FALSE)
