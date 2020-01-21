flextable_style <- function(flextable,
                            type = c("qom", 
                                     "completeness",
                                     "metadata")){
  
  # Formatting for all tables
  
  flextable %<>%
    
    # Add purple backgroud to header
    bg(bg = "#6c2c91", part = "header") %>%
    
    # Make header text white
    color(color = "white", part = "header") %>%
    
    # Make header text bold
    bold(part = "header") %>%
    
    # Add line after first column
    border(j = 1, border.right = fp_border("black")) %>%
    
    # Add outer border to whole table
    border_outer(fp_border("black"))
  
  # Formatting for Metadata
  
  if(type == "metadata"){
    
    flextable %<>%
      
      align(align = "center", part = "header") %>%
      align(j = 1, align = "right", part = "body") %>%
      align(j = 2, align = "left", part = "body") %>%
      valign(valign = "top", part = "body") %>%
      bold(j = 1, part = "body") %>%
      border(border = fp_border("black"), part = "all")
    
  }
  
  # Formatting for qom and completeness tables
  
  if(type %in% c("qom", "completeness")){
    
    flextable %<>%
      
      # Make Scotland row bold
      bold(~ geog == "Scotland") %>%
      
      # Add line above Scotland row
      border(~ geog == "Scotland",
             border.top = fp_border("black")) %>%
      
      # Left align first column
      # Right align the rest
      align(j = 1, align = "left", part = "all") %>%
      align(j = -1, align = "right", part = "all")
    
  }
    
  # Width/Height controls
  
  if(type == "qom"){
    
    flextable %<>%
      height_all(height = 0.225, part = "body") %>%
      height(height = 0.75, part = "header") %>%
      width(j = 1, width = 2.5) %>%
      width(j = -1, width = 1.4)
    
  }
  
  if(type == "completeness"){
    
    flextable %<>%
      height_all(height = 0.225, part = "body") %>%
      height(height = 0.75, part = "header") %>%
      width(j = 1, width = 2.5) %>%
      width(j = -1, width = 0.9)
    
  }
  
  if(type == "metadata"){
    
    flextable %<>%
      height(height = 0.75, part = "header") %>%
      width(j = 1, width = 2.1) %>%
      width(j = -1, width = 4.9) %>%
      
      # Due to a bug in flextable::autofit() function, the following code
      # is required to manually set the heights of each row depending on how
      # many rows of text are contained in each
      
      # 1 row
      height(i = c(1, 3:5, 8, 9, 11, 20, 25, 26:29), height = 0.25, part = "body") %>%
      # 2 rows
      height(i = c(7, 10, 13, 15, 16, 19, 21:24),
             height = 0.5,
             part = "body") %>%
      # 3 rows
      height(i = c(6, 13),
             height = 0.725,
             part = "body") %>%
      # 4 rows
      height(i = c(2, 12, 18),
             height = 1,
             part = "body") %>%
      # 6 rows
      height(i = 14,
             height = 1.5,
             part = "body") %>%
      # 11 rows
      height(i = 17,
             height = 2.75,
             part = "body")
    
  }

   flextable 
  
}