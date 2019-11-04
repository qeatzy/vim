
if !has('s:has_color_vanilla')
    try
        colorscheme vanila
        let s:has_color_vanilla = 1
    catch /E185/
        let s:has_color_vanilla = 0
    endtry
elseif s:has_color_vanilla
    colorscheme vanila
endif

