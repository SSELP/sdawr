# Update the site, just for updates
# If new file added, it will require manual check for index.
library(here)
library(rmarkdown)

git_status <- system("git status --porcelain", intern = TRUE)

# Filter for files ending in .Rmd that are Modified (M)
changed_files <- git_status[grepl("\\.Rmd$", git_status)]
# Clean the strings to get just the file paths
file_paths <- gsub("^\\s*\\S+\\s+", "", changed_files)

if (length(file_paths) == 0) {
    message("No changed Rmd files detected.")
} else {
    # 2. Knit changed Rmd files to HTML
    for (fn in file_paths) {
        message(paste("Knitting:", fn))
        
        ohtml <- here("docs", paste0(gsub("\\.Rmd", "", basename(fn)), ".html"))
        render(input = here(fn), output_file = ohtml)
    }
    
    # 3. Git commit and push
    # Add the Rmds and the newly generated HTMLs
    # Note there might be other updates as well.
    system("git add .") 
    
    commit_msg <- paste("Auto-knit updates for:", paste(basename(file_paths), collapse = ", "))
    system(paste0('git commit -m "', commit_msg, '"'))
    
    message("Pushing to GitHub...")
    system("git push")
}