flextable_style <- function(flextable){
  
  flextable %>%
    
    # Add purple backgroud to header
    bg(bg = "#6c2c91", part = "header") %>%
    
    # Make header text white
    color(color = "white", part = "header") %>%
    
    # Make header text bold
    bold(part = "header") %>%
    
    # Make Scotland row bold
    bold(~ geog == "Scotland") %>%
    
    # Add line above Scotland row
    border(~ geog == "Scotland",
           border.top = fp_border("black")) %>%
    
    # Add line after first column
    border(j = 1, border.right = fp_border("black")) %>%
    
    # Add outer border to whole table
    border_outer(fp_border("black")) %>%
    
    # Right align all but the first column
    align(j = -1, align = "right", part = "all") %>%
    
    # Control width/height of cells
    height_all(height = 0.225, part = "body") %>%
    height(height = 0.75, part = "header") %>%
    width(j = 1, width = 2.5) %>%
    width(j = -1, width = 1.4)
  
}