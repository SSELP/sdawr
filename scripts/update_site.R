# Update the site, just for updates
# If new file added, it will require manual check for index.
library(here)
library(stringr)
library(rmarkdown)
library(quarto)

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
}

# Filter class slides
changed_slides <- git_status[grepl("\\.qmd$", git_status)]
# Clean the strings to get just the file paths
slide_paths <- gsub("^\\s*\\S+\\s+", "", changed_slides)
slide_paths <- slide_paths[str_detect(slide_paths, "slides/")]

index_fn <- here("docs/index.Rmd")
current_class <- "Class 02"

if (length(slide_paths) == 0) {
    message("No changed qmd slides detected.")
} else {
    # 2. Knit changed qmd files to HTML
    for (fn in slide_paths) {
        message(paste("Knitting:", fn))
        
        ohtml <- here("docs", paste0(gsub("\\.qmd", "", basename(fn)), ".html"))
        render(input = here(fn), output_file = ohtml)
        quarto::quarto_render(
            input = here(fn),
            execute_dir = here("slides"))
        
        file.rename(gsub(".qmd", ".html", here(fn)), ohtml)
        
        # 3. Update index.Rmd
        cls_index <- str_extract(fn, "class[0-9]{1}")
        cls_index <- as.integer(gsub("class", "", cls_index))
        cls_index <- sprintf("Class %.2d", cls_index)
        
        x <- readLines(index_fn)
        idx <- grep(cls_index, x)
        
        if (length(idx) > 1) stop("Something is wrong with the index.")
        if (!str_detect(x[idx], basename(ohtml))){
            x[idx] <- gsub(cls_index, sprintf("[%s](%s)", cls_index, basename(ohtml)), x[idx])
        }
        
        writeLines(x, index_fn)
    }
    
    # 4. Update current week
    x <- readLines(index_fn)
    idx <- grep("<td class=\"current\">", x)
    x[idx] <- gsub("<td class=\"current\">", "<td>", x[idx])
    
    idx <- grep(current_class, x)
    if (!str_detect(x[idx], "current")){
        x[idx] <- gsub("<td>", "<td class=\"current\">", x[idx])
    }
    writeLines(x, index_fn)
    render(input = index_fn, output_file = gsub(".Rmd", ".html", index_fn))
}

# 5. Git commit and push
# Add the Rmds and the newly generated HTMLs
# Note there might be other updates as well.
system("git add .") 

commit_msg <- "Auto-knit updates for site:"
system(paste0('git commit -m "', commit_msg, '"'))

message("Pushing to GitHub...")
system("git push")
