library(readxl)
library(dplyr)

load_roster <- function(fn){
    dat <- read_xls(fn) %>% 
        slice(-c(1:6))
    colnames(dat) <- dat[1, ]
    dat[-1, ]
}

course_dir <- "/Users/leisong/Library/CloudStorage/Dropbox/teaching/Rutgers/sda320"

# Update students during the add/drop period
old_roster <- load_roster(file.path(course_dir, "excelSectionReportAllSections_26_01.xls"))
new_roster <- load_roster(file.path(course_dir, "excelSectionReportAllSections_30_01.xls"))

drop_students <- setdiff(old_roster, new_roster)
add_students <- setdiff(new_roster, old_roster)

drop_students$Student
paste0(add_students$`Net ID`, "@scarletmail.rutgers.edu")

# After add/drop period, update student's info
githubs <- c("zennaahmed", "stevenaraujov", "noa20-pixel", "ananya-bongoni", 
             "RohanDRU", "beg68", "DylanGong-1211", "", 
             "tino1360", "", "vblopez10", "fm455", 
             "", "am4403", "", "tpcherry101", 
             "lylatorr", "connorwoodcock", "yyelrahc")

repos <- c("za320", "SA320", "noa320", "asb320", 
           "rd320", "bg320", "DG320", "", 
           "sjl239", "", "", "", 
           "", "ag320", "", "", 
           "", "", "charley")

students <- new_roster %>% select(Student, `Net ID`) %>% 
    mutate(github = githubs, repo = repos)

save(students, file = file.path(course_dir, "students.rda"))
