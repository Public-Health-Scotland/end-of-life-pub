flextable_style <- function(flextable,
                            type = c("qom", 
                                     "completeness",
                                     "metadata",
                                     "calculations")){
  
  # Formatting for all tables
  
  flextable %<>%
    
    # Add purple backgroud to header
    bg(bg = "#3F3685", part = "header") %>%
    
    # Make header text white
    color(color = "white", part = "header") %>%
    
    # Make header text bold
    bold(part = "header") %>%

    # Set font as Arial
    font(part = "all", fontname = "Arial") %>%

    # Set font size as 12
    fontsize(part = "all", size = 12) %>%
    
    # Add line after first column
    border(j = 1, border.right = fp_border("black")) %>%
    
    # Add outer border to whole table
    border_outer(fp_border("black")) %>%

    # Add inner border to whole table
    border_inner(fp_border("black"))

  
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
  
  # Formatting for calculations
  
  if(type == "calculations"){
    
    flextable %<>%
      
      valign(valign = "top", part = "all") %>%
      align(align = "left", part = "all") %>%
      align(j = 2, align = "center", part = "all") %>%
      bold(part = "header") %>%
      border_remove() %>%
      border_outer(border = fp_border("black"), part = "all") %>%
      border_inner_h(border = fp_border("black"), part = "all")
    
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
      width(j = 1, width = 2.5) %>%
      width(j = -1, width = 1.4)
    
  }
  
  if(type == "completeness"){
    
    flextable %<>%
      width(j = 1, width = 2.5) %>%
      width(j = -1, width = 0.9)
    
  }
  
  if(type == "metadata"){
    
    flextable %<>%
      width(j = 1, width = 2.1) %>%
      width(j = -1, width = 4.9)
    
  }
  
  if(type == "calculations"){
    
    flextable %<>%
      
      width(j = 1, width = 2.5) %>%
      width(j = 2, width = 0.2) %>%
      width(j = 3, width = 4)
    
  }

   flextable %>% hrule(rule = "auto", part = "all")
  
}