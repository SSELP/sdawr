library(dplyr)

# Define directories
rutgers_dir <- "/Users/leisong/Library/CloudStorage/Dropbox/teaching/Rutgers"
course_dir <- file.path(rutgers_dir, "sda320")
ass_dir <- file.path(course_dir, "assignments")

# Load students
load(file.path(course_dir, "students.rda"))

# Define some common strings
sselp_url <- "git@github.com:SSELP/%s.git"
personal_url <- "git@github.com:%s/%s.git"

for (i in 1:nrow(students)){
    stu <- students %>% slice(i)
    message(sprintf("Student: %s, repo: %s", stu$Student, stu$repo))
    
    if (is.na(stu$sselp) | stu$github == "" | stu$repo == ""){
        next()
    }
    
    repo <- ifelse(stu$sselp == 1, sprintf(sselp_url, stu$repo),
                   sprintf(personal_url, stu$github, stu$repo))
    
    if (dir.exists(file.path(ass_dir, stu$repo))){
        system(sprintf("cd %s/%s; git pull; git fetch --all", ass_dir, stu$repo))
    } else{
        system(sprintf("cd %s; git clone %s", ass_dir, repo))
    }
}
