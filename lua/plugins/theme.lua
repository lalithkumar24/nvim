-- ================================================================================================
-- TITLE : themer.lua
-- ABOUT : A subtle, warm colorscheme for Neovim inspired from forost
-- LINKS :
--   > github : https://github.com/ribru17/bamboo.nvim
-- ================================================================================================


return {
	"xiyaowong/transparent.nvim",
  config = function()
    local transparent = require("transparent")
    transparent.setup({
      groups = {
        "Normal", "NormalNC", "Comment", "Constant", "Special", "Identifier",
        "Statement", "PreProc", "Type", "Underlined", "Todo", "String", "Function",
        "Conditional", "Repeat", "Operator", "Structure", "LineNr", "NonText",
        "SignColumn", "CursorLine", "CursorLineNr", "StatusLine", "StatusLineNC",
        "EndOfBuffer",
      },
    })
    transparent.clear() -- or transparent.toggle()
  end,
}
