library(readxl)
library(dplyr)

load_roster <- function(fn){
    dat <- read_xls(fn) %>% 
        slice(-c(1:6))
    colnames(dat) <- dat[1, ]
    dat[-1, ]
}

course_dir <- "/Users/leisong/Library/CloudStorage/Dropbox/teaching/Rutgers/sda320"

old_roster <- load_roster(file.path(course_dir, "excelSectionReportAllSections_23_01.xls"))
new_roster <- load_roster(file.path(course_dir, "excelSectionReportAllSections_26_01.xls"))

drop_students <- setdiff(old_roster, new_roster)
add_students <- setdiff(new_roster, old_roster)

drop_students$Student
paste0(add_students$`Net ID`, "@scarletmail.rutgers.edu")

githubs <- c("am4403", "connorwoodcock", "noa20-pixel", "ananya-bongoni", 
             "zennaahmed", "Lylatorr", "fm455", "djv93-svg", "divya-ananth", 
             "tpcherry101", "stevenaraujov")
